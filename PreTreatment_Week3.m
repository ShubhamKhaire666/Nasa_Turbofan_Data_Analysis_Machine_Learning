clc 
clear all
close all
M = readmatrix('data/train_FD001.txt');
vars =["unit number","time in cycles","op setting 1","op setting 2","op setting 3","sensor measurement 1","sensor measurement 2","sensor measurement 3","sensor measurement 4","sensor measurement5","sensor measurement 6","sensor measurement 7","sensor measurement 8","sensor measurement 9","sensor measurement 10","sensor measurement 11","sensor measurement 12","sensor measurement 13","sensor measurement 14","sensor measurement 15","sensor measurement 16","sensor measurement 17","sensor_measurement 18","sensor measurement 19","sensor measurement 20","sensor measurement 21"];

%% Calculating RUL
T = array2table(M);
T.Properties.VariableNames = vars;
T = convertvars(T,["unit number"],"categorical");

%Get Max Operating cycles for each engine
maxOperatingCycles = groupsummary(T,"unit number","max","time in cycles");
maxOperatingCycles = table2array(maxOperatingCycles(:,"GroupCount"));

%Create new column RUL
RUL = zeros(length(M),1);

%Populate it 
for i = 1:length(M)
    %Max operating cycle - current operating cycle
    RUL(i) = maxOperatingCycles(M(i,1)) - M(i,2);
end
M = [M RUL];

%% Remove sensor columns with zero standard deviation (constant values) and operational settings
M(:,[2,3,4,5,6, 10, 11, 15, 21, 23, 24]) = [];
vars(:,[2,3,4,5,6, 10, 11, 15, 21, 23, 24]) = [];

%% Splitting test data into test and validation (80% test 20% Val)
numDataPoints = 100;
numTrain = 80;

% Create random indices
randIndices = randperm(numDataPoints);

trainLog = logical(sum(M(:,1) == randIndices(1:numTrain),2));
testLog = logical(sum(M(:,1) == randIndices(numTrain+1:end),2));

%X matrices
XCal = M(trainLog,:);
XVal = M(testLog,:);

%RUL seperated
YCal = XCal(:,end);
YVal = XVal(:,end);

%Remove RUL from XCal and test partition
XCal(:,end) = [];
XVal(:,end) = [];

%Store Engine information in seperate array
ETrain = XCal(:,1);
ETest = XVal(:,1);

%Remove Engine Number from XCal and test partition
XCal(:,1) = [];
XVal(:,1) = [];

vars(:,1) = [];
%  Now XCal and XVal contain only sensor data acoounting to 14 variables
%% Normalise using z score method
%Center and scale the data
[XCal, mu, sigma] = zscore(XCal); 

% Apply the calibration center and standard deviation to the validation
% partition
XVal = normalize(XVal, 'Center', mu, 'Scale', sigma);

% --------------------------
% Do we need to center these??
% YCal   = YCal - mean(YCal);
% YVal   = YVal - mean(YCal); 

% box plot of sensor values for calibration data (normalized)
normalDataTable = array2table(XCal,"VariableNames",vars);
figure;
boxplot(normalDataTable{:,:}); 
xlabel('Variables');
ylabel('Values');
title('Box Plot of Sensor data (Normalized)');
xticklabels(vars); % Label x-axis with variable names
xtickangle(45); % for better readability


