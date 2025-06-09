import pandas as pd
import re
import numpy as np
from itertools import chain

df = pd.read_csv("jobkorea_nurse_merged.csv")
print("\n📊 This is the original dataset scrapped from jobkorea.co.kr, "
      "\n which is one of the most widely used recruitment website in Korea"
      "This is an exercise dataset, since it only contains records scrapped in one day")
# rename variable name
rename_dict = {
    "id": "job_id",
    "legacy_id": "job_legacyid",
    "title": "job_title",
    "company": "company_name",
    "postingCompany": "company_posting",
    "createdAt": "job_creat",
    "applicationStart": "job_applyon",
    "applicationEnd": "job_applyoff",
    "location": "job_location",
    "skills": "job_skill",
    "industry": "job_industry",
    "careerType": "job_type_code",
    "educationCode": "job_edu_code",
    "job_no": "job_no",
    "경력": "job_expr",
    "학력": "job_edu",
    "고용형태": "job_contract",
    "급여": "job_pay",
    "산업": "company_industry",
    "설립년도": "company_foundedyear",
    "기업형태": "company_type",
    "모집분야": "job_field",
    "모집인원": "job_quota",
    "지원자수": "applicants_total",
    "지원_남자": "applicants_male",
    "지원_여자": "applicants_female",
    "시간": "job_time",
    "시간_비고": "job_time_note",
    "지원_25세": "applicants_age_25below",
    "지원_2630세": "applicants_age_2630",
    "지원_3135세": "applicants_age_3135",
    "지원_3640세": "applicants_age_3640",
    "지원_4145세": "applicants_age_4145",
    "지원_46세": "applicants_age_46above",
    "지원_고졸미만": "applicants_edu_nohs",
    "지원_고졸(예정)": "applicants_edu_hs",
    "지원_초대졸(예정)": "applicants_edu_sclg",
    "지원_대졸(예정)": "applicants_edu_clg",
    "지원_석박사(예정)": "applicants_edu_grd",
    "복리후생_연금·보험": "benefit_insurance",
    "복리후생_보상·수당·지원": "benefit_bonus",
    "복리후생_휴무·휴가·행사": "benefit_holiday",
    "복리후생_사내제도·성장": "benefit_study",
    "복리후생_편의·여가·건강": "benefit_convenience"
}
df.rename(columns=rename_dict, inplace=True)


df.to_csv("jobkorea_nurse_cleaned.csv", index=False, encoding="utf-8-sig")
print("✅ Var name changed to: jobkorea_nurse_cleaned.csv")


# Values operation
df = pd.read_csv("jobkorea_nurse_cleaned.csv")

# Dates
for col in ["job_creat", "job_applyon", "job_applyoff"]:
    df[col] = pd.to_datetime(df[col], errors="coerce").dt.strftime("%Y-%m-%d")
df["company_foundedyear"] = df["company_foundedyear"].str.extract(r"(\d{4})").astype("Int64")

##A COMPANY##
#(1) company_type
# (1-i) specify keywords used in classification
type_keywords = {
    "대기업": "large",
    "중견기업": "midsize",
    "중소기업": "small",
    "벤처기업": "venture",
    "외국계": "foreign",
    "개인": "individual",
    "비영리": "nonprofit",
    "공공기관": "public",
    "계열사": "affiliate",
    "자회사": "affiliate"
}

# (1-ii) define and apply a function to categorize
def extract_company_type(text):
    if pd.isna(text):
        return "uncertain"
    for keyword, category in type_keywords.items():
        if keyword in text:
            return category
    return "uncertain"
df["company_type_eng"] = df["company_type"].apply(extract_company_type)

# (1-iii) create code for company types
category_map = {
    "large": 1,
    "midsize": 2,
    "small": 3,
    "venture": 4,
    "foreign": 5,
    "individual": 6,
    "nonprofit": 7,
    "public": 8,
    "affiliate": 9,
    "uncertain": 0
}
df["company_type_cat"] = df["company_type_eng"].map(category_map)

# (2) industry: use job_industry to classify instead of company_industry (reason: more detailed)
# (2-i) check all keywords
industry_col = "job_industry" if "job_industry" in df.columns else df.columns[0]
industry_vals = set()
for val in df[industry_col].astype(str):
    for kw in val.split('/'):
        kw = kw.strip()
        if kw and kw.lower() != 'nan':
            industry_vals.add(kw)
industry_list = sorted(industry_vals)
for i in industry_list:
    print(i)

# (2-ii) Classify special case first: pets related, beauty industry related,...
# (for example, 강아지(dog) 호텔(hotel), 애견(dog)  미용(beautician) are not in hospitality industry or beauty industry)
pet_keywords = ["애견", "강아지", "반려동물", "수의", "동물병원"]
medical_keywords = ["병원", "의원", "클리닉", "이비인후과", "내과", "외과", "정형외과", "소아과", "피부과", "치과"]
beauty_keywords = ["미용", "피부", "에스테틱", "성형", "보톡스"]
pharmacy_keywords = ["제약","바이오"]
finance_keywords = ["금융", "보험", "은행", "증권", "회계", "재무"]
education_keywords = ["교육", "학원", "학교", "유치원", "어린이집"]
it_keywords = ["it", "ict", "소프트웨어", "플랫폼", "erp", "crm", "ai", "앱", "3d프린터","5g","APP"]
logistics_keywords = ["물류", "배송", "운송", "택배"]
manufacturing_keywords = ["제조", "기계", "자동화", "전자", "반도체"]
hospitality_keywords = ["호텔", "숙박", "레스토랑", "음식점", "카페"]
construction_keywords = ["건설", "부동산", "건축", "인테리어", "주택"]
media_keywords = ["미디어", "방송", "광고", "콘텐츠"]

# (2-iii) Ordered classification
def classify_industry(text):
    if pd.isnull(text):
        return "Unclassified"
    if any(kw in text for kw in pet_keywords):
        return "Animal_Pet"
    elif any(kw in text for kw in medical_keywords):
        return "Medical_Healthcare"
    elif any(kw in text for kw in beauty_keywords):
        return "Beauty_Cosmetic"
    elif any(kw in text for kw in pharmacy_keywords):
        return "Finance_Insurance"
    elif any(kw in text for kw in finance_keywords):
        return "Finance_Insurance"
    elif any(kw in text for kw in education_keywords):
        return "Education"
    elif any(kw in text for kw in it_keywords):
        return "IT_Digital"
    elif any(kw in text for kw in logistics_keywords):
        return "Logistics"
    elif any(kw in text for kw in manufacturing_keywords):
        return "Manufacturing"
    elif any(kw in text for kw in hospitality_keywords):
        return "Hospitality"
    elif any(kw in text for kw in construction_keywords):
        return "Construction_RealEstate"
    elif any(kw in text for kw in media_keywords):
        return "Media_Advertising"
    else:
        return "Other"

df["Industry_Standardized"] = df["job_industry"].apply(classify_industry)

# (3) location
admin_df = pd.read_csv("kor_admin.csv")

# (3-i) preparation for administration region information
def clean_suffix(name, field):
    if pd.isna(name):
        return ""
    name = re.sub(r"(광역시|특별시|자치시|자치도|특별자치도)", "", name)
    name = re.sub(r"(시|도|군)$", "", name)
    if field in ["District", "City"] and len(name) == 2 and name.endswith("구"):
        return ""
    return name.strip()
admin_df["Province_Clean"] = admin_df["Province_Name_KR"].apply(lambda x: clean_suffix(x, "Province"))
admin_df["City_Clean"] = admin_df["City_Name_KR"].apply(lambda x: clean_suffix(x, "City"))
admin_df["District_Clean"] = admin_df["District_Name_KR"].apply(lambda x: clean_suffix(x, "District"))
duplicated_districts = admin_df["District_Clean"].duplicated(keep=False)
admin_df.loc[duplicated_districts, "District_Clean"] = ""


# (3-ii) keywords for both sides
province_keys = admin_df["Province_Clean"].dropna().unique().tolist()
city_keys = admin_df["City_Clean"].dropna().unique().tolist()
district_keys = admin_df["District_Clean"].dropna().unique().tolist()
df["match_text"] = df["job_location"].fillna('') + " " +  df["job_title"].fillna('')

# (3-iii) matching order: province, city, district
def match_region(row):
    text = row["match_text"]
    prov, city, dist = None, None, None

    for p in province_keys:
        if p and p in text:
            prov = p
            break

    if not prov:
        for c in city_keys:
            if c and c in text:
                city = c
                break

    if not prov and not city:
        for d in district_keys:
            if d and d in text:
                dist = d
                break

    return pd.Series([prov, city, dist])
df[["matched_province", "matched_city", "matched_district"]] = df.apply(match_region, axis=1)

city_to_prov_map = dict(zip(admin_df["City_Clean"], admin_df["Province_Clean"]))

# (3-iv) impute province and city
df.loc[
    df["matched_province"].isna() &  df["matched_city"].notna(),
    "matched_province"
] = df.loc[
    df["matched_province"].isna() &  df["matched_city"].notna(),
    "matched_city"
].map(city_to_prov_map)

df.loc[
    df["matched_province"].isna() & df["matched_district"].notna(),
    "matched_province"
] = df.loc[
    df["matched_province"].isna() & df["matched_district"].notna(),
    "matched_district"
].map(city_to_prov_map)
df.loc[
    df["matched_city"].isna() & df["matched_district"].notna(),
    "matched_city"
] = df.loc[
    df["matched_city"].isna() & df["matched_district"].notna(),
    "matched_district"
].map(city_to_prov_map)

prov_kr2en = admin_df.dropna(subset=["Province_Clean", "Province_Name"]).drop_duplicates("Province_Clean").set_index("Province_Clean")["Province_Name"].to_dict()
city_kr2en = admin_df.dropna(subset=["City_Clean", "City_Name"]).drop_duplicates("City_Clean").set_index("City_Clean")["City_Name"].to_dict()

# 匹配英文字段
df["company_province"] = df["matched_province"].map(prov_kr2en)
df["company_city"] = df["matched_city"].map(city_kr2en)

##B JOB##
# (1) job_field
# (1-i) specify keywords used in classification
job_field_categories = {
    "clinical_nurse": {
        "cat": 1,
        "keywords": ["간호사", "병동", "외래", "수술실", "중환자실", "응급실", "회복실", "검진센터", "입원", "응급"],
        "label": "Clinical_Nurse"
    },
    "assistant_staff": {
        "cat": 2,
        "keywords": ["조무사", "간호조무사", "치과조무사", "병원보조", "검사보조", "기록", "도우미"],
        "label": "Assistant"
    },
    "nonclinical_admin": {
        "cat": 3,
        "keywords": ["상담", "코디", "콜센터", "고객관리", "카운터", "접수", "보험", "심사", "행정", "수납", "청구", "서류"],
        "label": "Administration"
    },
    "research_edu_support": {
        "cat": 4,
        "keywords": ["연구", "교육", "임상시험", "컨설팅", "기술지원", "제품교육", "영업지원"],
        "label": "Tech_Edu"
    },
    "veterinary": {
        "cat": 5,
        "keywords": ["수의", "동물병원", "수의테크니션"],
        "label": "Veterinary"
    }
}

# (1-ii) define and apply a function to categorize
df["job_field_cat"] = 0
df["job_field_catname"] = "other"
for category in job_field_categories.values():
    cat = category["cat"]
    label = category["label"]
    for kw in category["keywords"]:
        mask = df["job_field"].fillna("").str.contains(kw, case=False, na=False)
        df.loc[mask, "job_field_cat"] = cat
        df.loc[mask, "job_field_catname"] = label


# (2) job_pay
# (2-i) operations: extract range of wage from text; create lower bound and upper bound; normalize to monthly pay
def parse_salary(s):
    if pd.isna(s):
        return np.nan, np.nan, np.nan
    s = s.strip()
    s_raw = s

    is_annual = "연봉" in s
    is_monthly = "월급" in s or "월" in s

    numbers = re.findall(r"(\d+)", s)
    numbers = list(map(int, numbers))

    lower, upper = np.nan, np.nan
    if len(numbers) == 1:
        lower = numbers[0]
    elif len(numbers) >= 2:
        lower, upper = numbers[0], numbers[1]

    if is_annual:
        if not np.isnan(lower):
            lower = round(lower / 12)
        if not np.isnan(upper):
            upper = round(upper / 12)

    return lower, upper, s_raw if any(kw in s for kw in ["면접", "회사내규", "협의", "결정", "수습"]) else np.nan

df[["job_pay_lower", "job_pay_upper", "job_pay_note"]] = df["job_pay"].apply(
    lambda x: pd.Series(parse_salary(x))
)


# (3)job_time
# (3-i) operations: extract work days and hours from text;
def parse_job_time(s):
    if pd.isna(s):
        return np.nan, np.nan, np.nan

    s = s.strip()

    weekday_count = np.nan
    dayon = np.nan
    dayoff = np.nan

    weekdays_full = "월화수목금토일"
    range_match = re.search(r"([월화수목금토일])\s*~\s*([월화수목금토일])", s)
    list_match = re.findall(r"[월화수목금토일]", s)
    week5_match = re.search(r"주\s*5일", s)

    if week5_match:
        weekday_count = 5
    elif range_match:
        start = weekdays_full.index(range_match.group(1))
        end = weekdays_full.index(range_match.group(2))
        if start <= end:
            weekday_count = end - start + 1
    elif list_match:
        weekday_count = len(set(list_match))

    time_match = re.search(r"(\d{1,2}:\d{2})\s*~\s*(\d{1,2}:\d{2})", s)
    if time_match:
        dayon = time_match.group(1)
        dayoff = time_match.group(2)

    return weekday_count, dayon, dayoff

df[["job_weekday", "job_dayon", "job_dayoff"]] = df["job_time"].apply(
    lambda x: pd.Series(parse_job_time(x))
)

# (4) job_skill
# (4-i) specify keywords for skills of nurse at workplace
SKILL_CLASS_KEYWORDS = {
    "Injection_BloodDraw_Infusion": [
        "주사", "IV잘하는", "채혈", "수액", "수액주사", "혈관확보", "혈액채취", "IV", "infusion", "injection", "채혈간호사", "수액실", "혈관주사"
    ],
    "Medical_Equipment_Operation_Management": [
        "의료기기", "의료기기관리", "의료기기조작", "장비", "장비관리", "기기관리", "기기", "장비도입", "소모품재고관리", "기기점검", "소모품관리", "장비유지보수", "기계설계", "장비점검", "기계공학"
    ],
    "Surgical_Preparation_Assistance": [
        "수술", "수술준비", "수술보조", "수술실", "수술파트", "수술장비", "마취보조", "수술환자관리", "수술어시스트", "수술준비물", "수술보조간호사", "수술환자이송", "마취"
    ],
    "Emergency_Response_CPR": [
        "응급처치", "CPR", "심폐소생술", "응급구조사", "응급실", "응급진료", "응급환자", "응급간호사", "응급중환자과", "응급조치", "응급지원", "심장충격기"
    ],
    "Medication_Administration": [
        "약제관리", "투약", "투약관리", "약품주문", "약국업무", "처방", "약품관리", "약품", "조제", "투약실", "약물감시", "약품재고관리", "약제", "약물관리", "조제실"
    ],
    "PR_Marketing_NewMedia_Content": [
        "홍보", "마케팅", "프로모션", "브랜딩", "광고", "블로그", "유튜브", "SNS", "콘텐츠", "카드뉴스", "Content", "Branding", "Promotion", "YouTube", "SNS컨텐츠", "마케터", "블로그운영", "유튜브영상제작", "SNS마케팅", "홍보마케팅"
    ],
    "Customer_Patient_Communication_Consultation": [
        "상담", "고객상담", "환자상담", "보호자상담", "게시판상담", "상담원", "간호상담원", "Customer Service", "Consultation", "고객미팅", "고객문의응대", "고객응대", "고객케어", "상담간호사"
    ],
    "Education_Training": [
        "교육", "강사", "트레이너", "교육자료", "교육전담간호사", "교육지원", "실습지도", "연수", "강의", "Lecture", "Training", "Instructor", "교육자료작성", "교육자료제작", "교육상담간호사"
    ],
    "Medical_Testing_Diagnostics": [
        "검사", "검진", "진단", "검사실", "진단검사", "초음파", "내시경", "영상의학", "영상촬영", "영상편집", "Lab", "Test", "Ultrasound", "Endoscope", "검안", "혈액검사", "영상의학과", "검체분석", "임상병리", "임상시험", "생화학"
    ],
    "Record_Document_Management": [
        "기록관리", "문서", "문서작성", "문서관리", "전산", "데이터관리", "프로그램", "시스템", "소프트웨어", "워드작성", "접수", "사무", "정보관리", "Data", "Record", "EMR", "OCS", "Excel", "서류", "서류관리", "서류작성", "행정", "행정지원"
    ],
    "Patient_Management_Basic_Nursing": [
        "환자관리", "병동간호", "활력징후", "체위변경", "석션", "배뇨관리", "이송", "보호자상담", "병동보조", "병동근무", "병동", "간호보조", "간호조무사", "간호조무", "간호지원", "간호사보조", "환자이동", "간병", "활력측정", "활력징후측정"
    ],
    "Infection_Control_Sterilization": [
        "감염관리", "감염예방", "멸균", "위생관리", "중앙멸균파트", "환경관리", "환경정리", "환경미화", "소독", "Sterilization", "Disinfection", "감염관리간호사", "소독관리", "소독실", "감염"
    ],
    "Inventory_Supply_Management": [
        "물품관리", "재고관리", "소모품재고관리", "약품주문", "약국업무", "재료관리", "자재관리", "약품재고관리", "기구관리", "소모품관리", "물품정리"
    ],
    "Medical_Billing_Insurance": [
        "보험금", "보험금청구", "보험설계", "보험설계사", "보험영업", "보험보장분석", "보험컨설팅", "보험tm", "진료비청구", "실손", "실손보험", "의료비", "의료비정산", "보험", "보험금청구", "보험관리"
    ],
    "Foreign_Language_International_Affairs": [
        "영어", "영어강사", "영어권", "국제학교", "외국인학교", "일본어", "중국어", "통번역", "영문", "영문해석", "외국어", "국제환자", "International", "Foreign Language"
    ],
    "Nursing_Assessment_Planning": [
        "간호평가", "건강진단", "건강검진", "건강관리", "건강상담", "건강증진", "건강증진센터", "간호계획", "간호과정", "간호평가간호사", "건강정보"
    ],
    "Teaching_Material_Instructional_Design": [
        "교육자료작성", "교육자료제작", "강의자료", "강의노트", "교육안내", "교재개발", "콘텐츠디자인", "강의계획서", "교육콘텐츠", "교안"
    ],
    "Quality_Management_Compliance": [
        "QA", "QC", "인증", "감사", "audit", "compliance", "심사", "심사대응", "품질관리", "품질검사", "품질보증", "품질개선", "품질담당자", "품질지원"
    ],
    "Home_Community_Nursing": [
        "방문간호", "방문간호사", "요양", "요양보호사", "가정간호", "지역간호", "방문요양센터", "홈케어", "방문", "지역보건", "Community Nursing", "Home Care"
    ],
    "Beauty_Skin_Esthetics": [
        "피부", "피부관리", "피부미용", "에스테틱", "레이저", "피부장비", "뷰티", "미용관리", "뷰티성형", "뷰티힐링바디케어", "바디케어", "스킨케어", "레이저실", "레이저어시", "미용의원", "성형", "성형외과", "미용", "피부과"
    ],
    "Veterinary_Animal_Care": [
        "동물간호", "동물간호사", "수의간호사", "동물간호복지사", "동물병원", "수의", "수의테크니션", "반려동물관리", "동물진료", "수의학", "애견관리", "애견유치원", "애견호텔"
    ],
    "Project_Management_RnD": [
        "프로젝트", "연구", "연구개발", "실험", "논문작성", "데이터분석", "개발", "제품설계", "개발관리", "과제관리", "Lab", "R&D"
    ],
    "Administration_Clerical_Support": [
        "행정", "행정지원", "사무", "사무지원", "접수", "문서", "문서작성", "문서관리", "전산", "정보관리", "데이터관리", "워드작성", "Data Entry", "Administration"
    ],
    "Sales_Business_Development": [
        "영업", "영업관리", "영업부", "영업전략", "영업지원", "고객관리", "고객상담", "고객관계관리", "고객미팅", "고객서비스", "고객센터", "고객케어", "마켓리서치", "신규고객발굴", "고객유치", "Sales", "Business Development"
    ],
    "IT_Systems_Data_Analysis": [
        "EMR", "OCS", "CRM", "ERP", "Excel", "전산", "데이터관리", "프로그램", "시스템", "소프트웨어", "IT", "SaaS", "네트워크", "Data Analysis"
    ],
    "Pharmacy_Consulting_Services": [
        "약사", "약국", "약국업무", "약품주문", "투약", "투약관리", "약제관리", "조제", "Dispensing", "Pharmacy"
    ],
    "HR_Recruitment": [
        "인사", "인사관리", "인재채용", "채용담당", "HR", "HRD", "HRM", "Recruitment", "Human Resource"
    ],
    "Nursing_Support_Assistance": [
        "간호보조", "간호조무사", "간호조무", "간호조무사님", "간호조무사(정규직)", "간호조무사(파트타임)", "조무사", "조무", "간호지원", "보조"
    ],
    "Environment_Safety_Cleaning_Mgmt": [
        "환경관리", "청결관리", "안전관리", "위생관리", "환경정리", "청소", "멸균", "시설관리", "청소관리", "위생", "청소원", "Safety", "Environment"
    ],
    "Hospital_Management_Operations": [
        "의료경영", "병원운영", "경영", "경영관리", "경영지원", "경영전략", "사업계획", "운영관리", "운영지원", "본부장", "관리자", "관리자급", "관리팀", "Hospital Management"
    ],
    "Finance_Accounting": [
        "회계", "회계관리", "회계학", "결산", "예산관리", "예산수립", "재무", "재무회계", "재무담당", "Accounting", "Finance"
    ],
    "Procurement_Supply_Chain": [
        "구매", "구매담당", "구매팀", "구매자재", "구매자재그룹", "발주", "발주관리", "발주서작성", "Procurement", "Supply Chain"
    ],
    "Transportation_Logistics": [
        "운송", "배송", "운반", "물류", "물류관리", "물류팀", "운송관리", "Logistics", "Transportation"
    ],
    "Catering_Nutrition_Management": [
        "급식관리", "식단관리", "식자재관리", "식자재검수", "식음료", "조리", "조리사", "배식", "Nutrition", "Catering"
    ],
    "Dermatology_Medical_Esthetics_Dept": [
        "피부과", "미용의원", "쁨의원", "비더뉴의원", "성형외과", "성형", "에스테틱"
    ],
    "Other_Unclassified": [
        "AE", "PA", "School", "FM매니저", "TSMC", "N전담", "b2b", "Generalist", "APM", "Affairs", "IV잘하는", "Part", "S", "amd", "ba", "Product", "C", "Associate"
    ]
}
def classify_job_skills(text, class_keywords):
    result = set()
    if pd.isnull(text):
        return []
    for kw in str(text).replace('/', ',').replace('|', ',').split(','):
        kw = kw.strip()
        if not kw:
            continue
        for class_name, keywords in class_keywords.items():
            for match_kw in keywords:
                if match_kw.lower() in kw.lower():
                    result.add(class_name)
    return list(result)

# (4-ii) create category variables (two forms)
df['job_task_vec'] = df['job_skill'].apply(lambda x: classify_job_skills(x, SKILL_CLASS_KEYWORDS))
df['job_task_str'] = df['job_task_vec'].apply(lambda x: '|'.join(x) if x else '')

# (4-iii) encode the tasks and get codebook
all_labels = set(chain.from_iterable(df['job_task_vec']))
label_to_code = {label: idx for idx, label in enumerate(sorted(all_labels))}
def encode_labels(label_list):
    codes = [label_to_code[label] for label in label_list if label in label_to_code]
    return codes, '|'.join(str(c) for c in codes)

df[['job_task_codevec', 'job_task_codestr']] = df['job_task_vec'].apply(
    lambda x: pd.Series(encode_labels(x))
)

codebook = pd.DataFrame([
    {'label': label, 'code': code}
    for label, code in label_to_code.items()
]).sort_values('code').reset_index(drop=True)
print(codebook)

# (5) basic requirement
# (5-i) experience
def extract_min_experience(text):
    if pd.isna(text):
        return 0
    numbers = list(map(int, re.findall(r'\d+', text)))
    if len(numbers) == 0:
        return 0
    return min(numbers)

df["job_experience"] = df["job_expr"].apply(extract_min_experience)

# (5-ii) cleaned education mapping
edu_map = [
    ("초대졸", "some_college"),
    ("대졸", "college"),
    ("고졸", "high_school"),
    ("학력무관", "no")
]

def map_education(text):
    if pd.isna(text):
        return "uncertain"
    for k, v in edu_map:
        if k in text:
            return v
    return "uncertain"

df["job_education"] = df["job_edu"].apply(map_education)


# (5-iii) contract type
df["job_contract_stripped"] = df["job_contract"].astype(str).str.replace(" ", "", regex=False)

df["job_regular"] = df["job_contract_stripped"].apply(lambda x: 1 if "정규직" in x else 0)
df["job_irregular"] = df["job_contract_stripped"].apply(lambda x: 1 if ("계약직" in x or "아르바이트" in x) else 0)
def extract_intern(text):
    match = re.search(r"수습\s*(\d+)", text)
    if match:
        return int(match.group(1))
    return 0
def extract_period(text):
    match = re.search(r"근무기간\s*(\d+)", text)
    if match:
        return int(match.group(1))
    return 0
df["job_intern"] = df["job_contract_stripped"].apply(extract_intern)
df["job_period"] = df["job_contract_stripped"].apply(extract_period)
df.loc[(df["job_irregular"] == 1) & (df["job_regular"] == 1), "job_regular"] = 0
df["job_trans"] = df["job_contract"].fillna("").apply(lambda x: 1 if "전환" in x else 0)
##D BENEFIT##
# (1) combine all text content of five benefit information groups (since some posts might mix up)
df["benefit_all"] = df[[
    "benefit_insurance", "benefit_bonus",
    "benefit_holiday", "benefit_study", "benefit_convenience"
]].fillna("").agg(" / ".join, axis=1)

# (2) specify the important aspects and corresponding keywords
benefit_keywords = {
    "benefit_insurance_national": ["국민연금"],
    "benefit_insurance_health": ["건강보험"],
    "benefit_insurance_employ": ["고용보험"],
    "benefit_insurance_injury": ["산재보험"],
    "benefit_insurance_retire": ["퇴직연금"],

    "benefit_bonus_retire": ["퇴직금", "퇴직연금"],
    "benefit_bonus_overtime": ["야간근로수당", "연장근로수당", "휴일근로수당", "특근수당", "당직비", "비상근무수당"],
    "benefit_bonus_performance": ["우수사원", "인센티브", "성과급", "분기포상"],
    "benefit_bonus_seniority": ["근속수당", "장기근속", "연차수당", "명절상여금"],
    "benefit_bonus_support": ["가족수당", "경조사비", "복지포인트", "휴가비", "통신비", "차량유지비", "자기개발비", "교육비", "복지카드", "의료비","자녀교육"],

    "benefit_holiday_annual": ["연차"],
    "benefit_holiday_family": ["경조", "결혼", "상조", "가족돌봄"],
    "benefit_holiday_mother": ["출산", "육아"],
    "benefit_holiday_father": ["배우자", "남성"],
    "benefit_holiday_sick": ["병가", "건강검진", "유급"],

    "benefit_edu": [
        "교육지원", "교육비", "자격증", "수강",
        "어학지원", "자기계발비", "학자금", "시험응시료","해외연수"
    ],

    "benefit_food": ["중식", "석식", "조식", "식사", "식대", "삼시세끼", "간식", "식권", "식비", "구내식당"],

    "benefit_live": ["기숙사", "숙소", "사택", "생활관", "하숙비", "기숙비"],

    "benefit_transport": [
        "통근버스", "셔틀버스", "교통비 지원", "교통비 지급", "교통비", "차량", "주차장",
        "주차비", "차비", "출퇴근버스", "통근수단", "교통편의", "교통지원", "유류비"
    ]
}

# (3) apply all keywords to classify benefits
for varname, keywords in benefit_keywords.items():
    df[varname] = df["benefit_all"].apply(
        lambda x: int(any(k in str(x) for k in keywords))
    )


## ENDING ##
df.to_csv("jobkorea_nurse_cleaned.csv", index=False, encoding="utf-8-sig")
print("✅ Cleaned and saved as jobkorea_nurse_cleaned.csv")

selected_columns = [
    "job_id", "company_name","job_task_str","job_task_vec","job_task_codevec", "job_task_codestr","job_creat", "job_applyon", "job_applyoff","job_experience",
    "job_education","job_regular","job_irregular","job_intern","job_period","job_trans","company_foundedyear","job_quota",
    "applicants_total","applicants_male","applicants_female","applicants_age_25below","applicants_age_2630",
    "applicants_age_3135","applicants_age_3640","applicants_age_4145","applicants_age_46above","applicants_edu_nohs",
    "applicants_edu_hs","applicants_edu_sclg","applicants_edu_clg","applicants_edu_grd","company_type_eng","company_type_cat",
    "Industry_Standardized","company_province","company_city","job_field_cat","job_field_catname","job_pay_lower","job_pay_upper",
    "job_weekday","job_dayon","job_dayoff","benefit_insurance_national","benefit_insurance_health",
    "benefit_insurance_employ","benefit_insurance_injury","benefit_insurance_retire","benefit_bonus_retire","benefit_bonus_overtime",
    "benefit_bonus_performance","benefit_bonus_seniority","benefit_bonus_support","benefit_holiday_annual","benefit_holiday_family",
    "benefit_holiday_mother","benefit_holiday_father","benefit_holiday_sick","benefit_edu","benefit_food","benefit_live","benefit_transport"
]
selected_df = df[selected_columns]
selected_df.to_csv("jobkorea_sample.csv", index=False, encoding="utf-8-sig")


