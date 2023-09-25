clc 
clear all
close all

% Load Data
M = readmatrix('data/RUL_FD001.txt');

% Test = readmatrix('data/test_FD001.txt');

M = readmatrix('data/train_FD001.txt');
% 
% RUL = readmatrix('data/RUL_FD001.txt');

vars =["unit number","time in cycles","op setting 1","op setting 2","op setting 3","sensor measurement 1","sensor measurement 2","sensor measurement 3","sensor measurement 4","sensor measurement5","sensor measurement 6","sensor measurement 7","sensor measurement 8","sensor measurement 9","sensor measurement 10","sensor measurement 11","sensor measurement 12","sensor measurement 13","sensor measurement 14","sensor measurement 15","sensor measurement 16","sensor measurement 17","sensor_measurement 18","sensor measurement 19","sensor measurement 20","sensor measurement 21"];

%% Splitting test data into test and validation (70% test 30% Val)
no_Train = 0;
for i = 1:80
    time = M(:, 1) == i;
    no_Train = no_Train + sum(time);
end

Train = M(1:no_Train,:);
Testing = M(no_Train+1:end,:);

%% Remove sensor columns with zero standard deviation (constant values)
Train(:,[6, 10, 11, 15, 21, 23, 24]) = [];
vars(:,[6, 10, 11, 15, 21, 23, 24]) = [];
% changed the array to a table
trainTable = array2table(Train, 'VariableNames', vars);

% Get only the sensor data values for further analysis
sensorData = Train(:,6:end);

%% Normalise using z score method
normalData = zscore(sensorData);
normalDataTable = array2table(normalData, 'VariableNames', vars(6:end));

% box plot of sensor values (normalized)
%Show this plot in the report
%Explain how the scale of the vriables is quite similar compared to what we
%saw last week (show previous bar plot)
figure;
boxplot(normalDataTable{:,:}); % Excluding the first two columns
xlabel('Variables');
ylabel('Values');
title('Box Plot of Sensor data (Normalized)');
xticklabels(vars(6:end)); % Label x-axis with variable names
xtickangle(45); % for better readability

%% Performing PCA on the sensor data
[coeff,score,latent,T2W,explained]= pca(normalData);

%Variance explained by PC
explained
figure()
pareto(explained);
xlabel('Principal Component')
ylabel('Variance Explained (%)')
title("Variation explained by different PC")

% From the pareto graph it can be seen that top 3 PC explain 80% of data

%% bi plot of first 2 PC
figure
biplot(coeff(:,1:2),'Scores',score(:,1:2),'Varlabels',vars(6:end))
title("Biplot of first 2 PC");

% Barplot to visualize the loading coefficients
figure('Name', 'Loading bar plot')
bar(coeff(:,1)');
xticks(1:length(vars(6:end))); % Set the x-axis tick positions
xticklabels(vars(6:end)); 
xlabel('Variables');
ylabel('Loading Coefficients');
title('Loading Barplot for the First Principal Component');

%% T2
%Explain what T2 graph is ans we will be using it to detect outliers
figure('Name', 'T2 Square Score')
% Calculate control limits (assuming 3 standard deviations)
T2_mean = mean(T2W);
T2_std = std(T2W);

%The outlier boundry is set according to formulae below
T2_upper_limit = T2_mean + 3 * T2_std;

a = 1:length(T2W);
plot(a,T2W), hold on
plot(a,T2_upper_limit*ones(size(T2W)),'r--')
xlabel("Sample");
ylabel("T2 Square score");


% Remove values that are outliers from score matrix
score = score(T2W > T2_upper_limit == 0, :);

%bi plot after removal shows some extreme values removed from the biplot
%above
figure
biplot(coeff(:,1:2),'Scores',score(:,1:2),'Varlabels',vars(6:end))
title("Biplot of first 2 PC");

