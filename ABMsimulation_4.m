% Here is a replication for this paper:
% Fabian Baumann, Philipp Lorenz-Spreen, Igor M. Sokolov, and Michele Starnini. 2020. “Modeling Echo Chambers and Polarization Dynamics in Social Networks.” Physical Review Letters 124(4):048301. doi: 10.1103/PhysRevLett.124.048301.

% The procedure mainly involves 3 tasks:
% 1. Basic setting of agent-based model
% 2. Solving diffrential equations system by fourth-order Runge-Kutta method
% 3. Numerical simulation plots


% SIMU(a)
% Step 1: Initialize parameters
N = 1000;               % Number of agents
dt = 0.01;              % Time step
T = 1000;               % Total time steps
m = 10;                 % Contacts per active agent
epsilon = 0.01;         % Minimum activity level
gamma = 2.1;            % Activity distribution exponent
r = 0.5;                % Reciprocity
K = 3;                  % Influence strength
alpha = 0.05;           % Contraversialness
beta = 2;               % Homophily level
rng('default');          
rng(1);                
% Initialize opinions randomly in [-1, 1]
x = -1 + 2 * rand(N, 1);

u = rand(1, N);
a = (epsilon^(1 - gamma) + u * (1^(1 - gamma) - epsilon^(1 - gamma))).^(1 / (1 - gamma));

% Prepare for simulation
A = zeros(N);  % Adjacency matrix
time = 0:dt:T*dt;  % Time vector
x_store = zeros(length(time), N);  % Store opinions over time
x_store(1, :) = x;  % Initial opinions

% Run simulation for Aij(t)
for t = 2:length(time)
    A(:) = 0;  % Clear adjacency matrix each step

    % Activate agents
    for i = 1:N
        if rand < a(i) % if i is activated
% Compute influence probabilities for all agents j relative to i
            prob = abs(x(i) - x).^(-beta);  % Vector of influence probabilities 
            prob(i) = 0;  % No self-links
            probs = prob / sum(prob); % pij
% Randomly choose m agents based on weighted probabilities
% targets = randsample(1:N, m,true, probs);  % 'true' allows sampling with replacement
targets = datasample(1:N, m, 'Replace', false, 'Weights', probs); % without replacement

            % Loop through the selected top m targets
            for j = targets
                A(j, i) = 1;  % i influences j           
                % Reciprocal link
                if rand < r
                    A(i, j) = 1;  % j reacts i with probability r
                end
            end
        end
    end

   % Update opinions using Runge-Kutta 4 method
   f = @(x) -x + K * A * tanh(alpha * x); 
    k1 = f(x);
    k2 = f(x + 0.5 * dt * k1);
    k3 = f(x + 0.5 * dt * k2);
    k4 = f(x + dt * k3);
    x = x + dt / 6 * (k1 + 2 * k2 + 2 * k3 + k4);

    % Store opinions for each t
    x_store(t, :) = x;
end

%Plot results
fig_a = figure('Name', 'simu_a');
plot(time, x_store .* (x_store >= 0), 'b', 'LineWidth', 0.2);
hold on;
plot(time, x_store .* (x_store < 0), 'r', 'LineWidth', 0.2);
hold off;
title('Temporal evolution of opinions, \alpha=0.05,\beta=2','FontSize', 14);
xlabel('Time');
ylabel('Opinion');
set(gca, 'Toolbar', []);
exportgraphics(gcf, 'echopaper/simu_a.png', 'Resolution', 300);
%% 




% SIMU(b)
% Step 1: Initialize parameters
N = 1000;                % Number of agents
dt = 0.01;              % Time step
T = 1000;               % Total time steps
m = 10;                 % Contacts per active agent
epsilon = 0.01;         % Minimum activity level
gamma = 2.1;            % Activity distribution exponent
r = 0.5;                % Reciprocity
K = 3;                  % Influence strength
alpha = 3;              % Controversialness
beta = 0;               % Homophily level
rng('default');
rng(1);
% Initialize opinions randomly in [-1, 1]
x = -1 + 2 * rand(N, 1);

u = rand(1, N);
a = (epsilon^(1 - gamma) + u * (1^(1 - gamma) - epsilon^(1 - gamma))).^(1 / (1 - gamma));

% Prepare for simulation
A = zeros(N);  % Adjacency matrix
time = 0:dt:T*dt;  % Time vector
x_store = zeros(length(time), N);  % Store opinions over time
x_store(1, :) = x;  % Initial opinions

% Run simulation for Aij(t)
for t = 2:length(time)
    A(:) = 0;  % Clear adjacency matrix each step

    % Activate agents
    for i = 1:N
        if rand < a(i) % if i is activated
% Compute influence probabilities for all agents j relative to i
            prob = abs(x(i) - x).^(-beta);  % Vector of influence probabilities 
            prob(i) = 0;  % No self-links
            probs = prob / sum(prob); % pij
% Randomly choose m agents based on weighted probabilities
% targets = randsample(1:N, m,true, probs);  % 'true' allows sampling with replacement
targets = datasample(1:N, m, 'Replace', false, 'Weights', probs); % without replacement

            % Loop through the selected top m targets
            for j = targets
                A(j, i) = 1;  % i influences j           
                % Reciprocal link
                if rand < r
                    A(i, j) = 1;  % j reacts i with probability r
                end
            end
        end
    end

   % Update opinions using Runge-Kutta 4 method
   f = @(x) -x + K * A * tanh(alpha * x); 
    k1 = f(x);
    k2 = f(x + 0.5 * dt * k1);
    k3 = f(x + 0.5 * dt * k2);
    k4 = f(x + dt * k3);
    x = x + dt / 6 * (k1 + 2 * k2 + 2 * k3 + k4);

    % Store opinions for each t
    x_store(t, :) = x;
end

% Step 3: Plot results
fig_b = figure('Name', 'simu_b');
plot(time, x_store .* (x_store >= 0), 'b', 'LineWidth', 0.2);
hold on;
plot(time, x_store .* (x_store < 0), 'r', 'LineWidth', 0.2);
hold off;
title('Temporal evolution of opinions, \alpha=3,\beta=0','FontSize', 14);
xlabel('Time');
ylabel('Opinion');
set(gca, 'Toolbar', []);
exportgraphics(gcf, 'echopaper/simu_b.png', 'Resolution', 300);
%% 

% SIMU(c)
% Step 1: Initialize parameters
N = 1000;                % Number of agents
dt = 0.01;              % Time step
T = 1000;               % Total time steps
m = 100;                 % Contacts per active agent
epsilon = 0.01;         % Minimum activity level
gamma = 2.1;            % Activity distribution exponent
r = 0.5;                % Reciprocity
K = 3;                  % Influence strength
alpha = 3;              % Controversialness
beta = 3;               % Homophily level
rng('default');
rng(1);
% Initialize opinions randomly in [-1, 1]
x =  rand(N, 1);

u = rand(1, N);
a = (epsilon^(1 - gamma) + u * (1^(1 - gamma) - epsilon^(1 - gamma))).^(1 / (1 - gamma));


% Prepare for simulation
A = zeros(N);  % Adjacency matrix
time = 0:dt:T*dt;  % Time vector
x_store = zeros(length(time), N);  % Store opinions over time
x_store(1, :) = x;  % Initial opinions

% Run simulation for Aij(t)
for t = 2:length(time)
    A(:) = 0;  % Clear adjacency matrix each step

    % Activate agents
    for i = 1:N
        if rand < a(i) % if i is activated
% Compute influence probabilities for all agents j relative to i
            prob = abs(x(i) - x).^(-beta);  % Vector of influence probabilities 
            prob(i) = 0;  % No self-links
            probs = prob / sum(prob); % pij
% Randomly choose m agents based on weighted probabilities
% targets = randsample(1:N, m,true, probs);  % 'true' allows sampling with replacement
targets = datasample(1:N, m, 'Replace', false, 'Weights', probs); % without replacement

            % Loop through the selected top m targets
            for j = targets
                A(j, i) = 1;  % i influences j           
                % Reciprocal link
                if rand < r
                    A(i, j) = 1;  % j reacts i with probability r
                end
            end
        end
    end

   % Update opinions using Runge-Kutta 4 method
   f = @(x) -x + K * A * tanh(alpha * x); 
    k1 = f(x);
    k2 = f(x + 0.5 * dt * k1);
    k3 = f(x + 0.5 * dt * k2);
    k4 = f(x + dt * k3);
    x = x + dt / 6 * (k1 + 2 * k2 + 2 * k3 + k4);

    % Store opinions for each t
    x_store(t, :) = x;
end
%% 

% Step 3: Plot results
fig_c = figure('Name', 'simu_c');
plot(time, x_store .* (x_store(1,:) >= 0), 'b', 'LineWidth', 0.2);
hold on;
plot(time, x_store .* (x_store(1,:) < 0), 'r', 'LineWidth', 0.2);
hold on;
plot(time, x_store .* (x_store(1000,:) >= 10), 'g', 'LineWidth', 0.2);
hold off;
title('Temporal evolution of opinions, \alpha=3,\beta=3','FontSize', 14);
xlabel('Time');
ylabel('Opinion');
set(gca, 'Toolbar', []);
exportgraphics(gcf, 'echopaper/simu_c.png', 'Resolution', 300)

%% 
% Combined figure
fig_combined = figure('Name', 'Combined', 'Position', [100, 100, 900, 600]);

% (a) Top-left plot
subplot(2, 2, 1);  % 2x2 grid, position 1
ax_a = findobj(fig_a, 'Type', 'axes');  
copyobj(allchild(ax_a), gca);  
title('(a)','FontSize', 16);

% (b) Bottom-left plot
subplot(2, 2, 3);  % 2x2 grid, position 3
ax_b = findobj(fig_b, 'Type', 'axes');
copyobj(allchild(ax_b), gca);
title('(b)','FontSize', 16);

% (c) Right-side plot spanning two rows
subplot(2, 2, [2, 4]); 
ax_c = findobj(fig_c, 'Type', 'axes');
copyobj(allchild(ax_c), gca);
title('(c)','FontSize', 16);

% Save the combined figure
exportgraphics(gcf, 'echopaper/simu.png', 'Resolution', 300);
