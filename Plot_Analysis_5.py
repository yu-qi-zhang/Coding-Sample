import pandas as pd
import numpy as np
import geopandas as gpd
import ast
import seaborn as sns
from scipy import stats
from itertools import combinations
from scipy.stats import pearsonr,spearmanr,f_oneway,kruskal,shapiro,mannwhitneyu
import statsmodels.api as sm
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, BoundaryNorm
import matplotlib.patches as mpatches



df = pd.read_csv("jobkorea_sample.csv")

#A Statistical Analysis
#A1 Correlation between range of wage and required education
print("\n1️⃣ Check available obs for wage information (Note: most position posts don't provide wage range explicitly)")
print("Counts: job_pay_lower = ", df["job_pay_lower"].notna().sum())
for edu in df["job_education"].dropna().unique():
    vals = df[df["job_education"] == edu]["job_pay_lower"].dropna()
    if len(vals) >= 3:
        pval = shapiro(vals).pvalue
        print(f"{edu}: n = {len(vals)}, Shapiro-Wilk p = {pval:.4f}")
print("\n2️⃣ Check whether the wages differ by education requirements")
edu_focus = ["no", "high_school","some_college","college"]
edu_available = [edu for edu in edu_focus if edu in df["job_education"].unique()]
groups = [df[df["job_education"] == edu]["job_pay_lower"].dropna() for edu in edu_available]
f_stat, p_val = f_oneway(*groups)
print("ANOVA F-stat:", f_stat, "p-value:", p_val)
h_stat, p_val = kruskal(*groups)
print("Kruskal-Wallis H-stat:", h_stat, "p-value:", p_val)

print("\n3️⃣ Pairwise Comparison （Note: not Normally distributed, so test on medium)")
edu_levels = df["job_education"].dropna().unique()
edu_pairs = list(combinations(edu_levels, 2))
for pair in edu_pairs:
    group1 = df[df["job_education"] == pair[0]]["job_pay_upper"].dropna()
    group2 = df[df["job_education"] == pair[1]]["job_pay_upper"].dropna()
    if len(group1) >= 3 and len(group2) >= 3:
        stat, p = mannwhitneyu(group1, group2, alternative='two-sided')
        print(f"{pair[0]} vs {pair[1]}: U-stat = {stat:.2f}, p-value = {p:.4f}")
print("\n📖Rough Story: much difference in provided wages between positions requiring for high school degree and college degree")


#A2 Analysis: what feature would attract applicants?
print("\n4️⃣A poisson regression for number of applicants")
print("\n🙋Here is some information not available on website explicitly: how many users have applied for this position?")
df["tellwage"] = ((~df["job_pay_lower"].isna()) | (~df["job_pay_upper"].isna())).astype(int)
def impute_lower(row, group_lower):
    if not pd.isna(row["job_pay_lower"]):
        return row["job_pay_lower"]
    key = (row["job_pay_upper"], row["job_task_codestr"])
    if key in group_lower:
        return group_lower[key]
    if not pd.isna(row["company_province"]):
        return df[df["company_province"] == row["company_province"]]["job_pay_lower"].mean()
    return 0

group_lower = df.groupby(["job_pay_upper", "job_task_codestr"])["job_pay_lower"].mean().to_dict()
df["job_pay_lower_filled"] = df.apply(lambda row: impute_lower(row, group_lower), axis=1)

df["job_weekday_filled"] = df["job_weekday"]
df.loc[df["job_weekday_filled"].isna() & (df["job_regular"] == 1), "job_weekday_filled"] = 5
df["irregular_weekday"] = df["job_irregular"] * df["job_weekday_filled"]
df["job_daily_wage"] = df["job_pay_lower_filled"] / df["job_weekday_filled"]
df["tellwage_lower"] = df["tellwage"] * df["job_daily_wage"]

df["job_post_days"] = (pd.to_datetime("2025-06-05") - pd.to_datetime(df["job_applyon"])).dt.days
df["job_insurance"] = (
    df["benefit_insurance_national"] +
    df["benefit_insurance_health"] +
    df["benefit_insurance_employ"] +
    df["benefit_insurance_injury"] +
    df["benefit_insurance_retire"]
)

poisson_data = df[
    ["applicants_total", "job_post_days", "irregular_weekday", "job_regular","tellwage_lower","tellwage","job_insurance"]
].dropna()

model = smf.glm(
    formula="applicants_total ~ job_post_days + job_regular + irregular_weekday+tellwage_lower+tellwage+job_insurance",
    data=poisson_data,
    family=sm.families.Poisson()
).fit()
poisson_data = poisson_data[poisson_data["job_post_days"] > 0]
poisson_data = poisson_data[poisson_data["applicants_total"].notna()]
poisson_data = poisson_data[poisson_data["applicants_total"] >= 0]
poisson_data = poisson_data.dropna()
poisson_data["log_days"] = np.log(poisson_data["job_post_days"])
model = sm.GLM(
    poisson_data["applicants_total"],
    sm.add_constant(poisson_data[["job_regular", "irregular_weekday", "tellwage_lower", "tellwage", "job_insurance"]]),
    family=sm.families.Poisson(),
    offset=poisson_data["log_days"]
).fit()
print(model.summary())
print("📖Rough Story: insurance, regular job and more work days for irregular job could attract applicants"
      ",\n while wage, on the contrary, does not show much influence here."
      "However, one explanation is that for positions without wage information released, people have to click 'apply' to get this information.")

#B plots
print("\n5️⃣Map plots")
#B1 skill demand across regions
print("\n🏥 I want to see distribution across regions of these posted positions")
# B1-1 preparation
shp_path = "mapKorea/gadm41_KOR_2.shp"
gdf = gpd.read_file(shp_path)
citydata = gdf[["GID_1", "NAME_1", "GID_2", "NAME_2"]].copy()
citydata.columns = ["Province_ID", "Province_Name", "City_ID", "City_Name"]

sample_df = pd.read_csv("jobkorea_sample.csv")
NURSE_MAIN_KEYWORDS = [
    "Injection_BloodDraw_Infusion",
    "Medical_Equipment_Operation_Management",
    "Surgical_Preparation_Assistance",
    "Emergency_Response_CPR",
    "Medical_Testing_Diagnostics",
    "Infection_Control_Sterilization"
]

sample_df["nurse_main"] = sample_df["job_task_vec"].apply(
    lambda x: int(any(skill in ast.literal_eval(x) for skill in NURSE_MAIN_KEYWORDS)) if isinstance(x, str) else 0
)
print(sample_df[["nurse_main"]].describe())

count_city_all = sample_df.dropna(subset=["company_city"]).groupby("company_city").size().reset_index(name="count_all_city")
count_city_main = sample_df.dropna(subset=["company_city"])
count_city_main = count_city_main[count_city_main["nurse_main"] == 1].groupby("company_city").size().reset_index(name="count_main_city")
only_prov_df = sample_df[sample_df["company_city"].isna() & sample_df["company_province"].notna()]
count_prov_all = only_prov_df.groupby("company_province").size().reset_index(name="count_all_prov")
count_prov_main = only_prov_df[only_prov_df["nurse_main"] == 1].groupby("company_province").size().reset_index(name="count_main_prov")
size_prov = citydata.groupby("Province_Name").size().reset_index(name="size_prov")

citydata = citydata.merge(count_city_all, how="left", left_on="City_Name", right_on="company_city")
citydata = citydata.merge(count_city_main, how="left", left_on="City_Name", right_on="company_city")
citydata = citydata.merge(count_prov_all, how="left", left_on="Province_Name", right_on="company_province")
citydata = citydata.merge(count_prov_main, how="left", left_on="Province_Name", right_on="company_province")
citydata = citydata.merge(size_prov, how="left", on="Province_Name")

citydata[["count_all_city", "count_main_city", "count_all_prov", "count_main_prov"]] = citydata[
    ["count_all_city", "count_main_city", "count_all_prov", "count_main_prov"]
].fillna(0)
citydata["count_all"] = citydata["count_all_city"] + (citydata["count_all_prov"] /citydata ["size_prov"])
citydata["count_main"] = citydata["count_main_city"] + (citydata["count_main_prov"] / citydata["size_prov"])
gdf = gdf.rename(columns={"NAME_1": "Province_Name", "NAME_2": "City_Name"})
gdf_merged = gdf.merge(
    citydata[["Province_Name", "City_Name", "count_main","count_all"]],
    on=["Province_Name", "City_Name"],
    how="left"
)
gdf_merged["count_main"] = gdf_merged["count_main"].fillna(0)
gdf_merged["count_all"] = gdf_merged["count_all"].fillna(0)

# B1-2: plots
def plot_combined_maps(df, var1, var2, title1, title2, legend_title, filename):
    colors = ["#f0f9ff", "#ccece6", "#99d8c9", "#66c2a4", "#2ca25f", "#006d2c"]
    cmap = ListedColormap(colors)
    norm = BoundaryNorm(boundaries=[-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5], ncolors=6)

    for var in [var1, var2]:
        nonzero = df.loc[df[var] > 0, var]
        quintile = pd.qcut(nonzero, 5, labels=False, duplicates="drop") + 1
        class_var = f"{var}_class"
        df[class_var] = 0
        df.loc[df[var] > 0, class_var] = quintile

    fig, axs = plt.subplots(1, 2, figsize=(20, 10))

    df.plot(column=f"{var1}_class", cmap=cmap, norm=norm, linewidth=0.4, edgecolor="gray", ax=axs[0])
    axs[0].set_title(title1,fontdict={
        'fontsize': 20,
        'fontweight': 'bold',
        'fontfamily': 'Times New Roman'
    })
    axs[0].axis("off")

    df.plot(column=f"{var2}_class", cmap=cmap, norm=norm, linewidth=0.4, edgecolor="gray", ax=axs[1])
    axs[1].set_title(title2, fontdict={
        'fontsize': 20,
        'fontweight': 'bold',
        'fontfamily': 'Times New Roman'
    })
    axs[1].axis("off")

    legend_labels = [
        "No post (0)",
        "1st quintile",
        "2nd quintile",
        "3rd quintile",
        "4th quintile",
        "5th quintile"
    ]
    handles = [mpatches.Patch(color=colors[i], label=legend_labels[i]) for i in range(6)]

    fig.legend(
        handles=handles,
        title=legend_title,
        loc="center right",
        bbox_to_anchor=(0.95, 0.3),
        frameon=True,
        borderpad=1,
        fontsize=11,
        title_fontsize=12
    )

    plt.tight_layout(rect=[0, 0,0.95, 0.95])
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()

plot_combined_maps(
    gdf_merged,
    var1="count_all",
    var2="count_main",
    title1="All Nurse Job Posts",
    title2="Specialized Nurse Job Posts",
    legend_title="Quintiles",
    filename="combined_map.png"
)
