% This file contains up to date code including the pretreatment and PLS
% implementation
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

%% Calculating the PLS for 1:14 LV. Computing 
for i = 1:size(XCal,2)
    [modelPLS(i).P , modelPLS(i).T, modelPLS(i).Q, modelPLS(i).U, ...
        modelPLS(i).beta, modelPLS(i).var, modelPLS(i).MSE, modelPLS(i).stats] = plsregress(XCal, YCal, i);

   % Calculating Yhat
   n = length(YCal);
   modelPLS(i).Yhat       = [ones(n,1) XCal] * modelPLS(i).beta;
 
   % Predicting the validation set
   m = length(YVal);
   modelPLS(i).YPred    = [ones(m,1) XVal] * modelPLS(i).beta;

   modelPLS(i).TSS      = sum((YCal - mean(YCal)).^2); 

    %R2
    modelPLS(i).RSS      = sum((YCal - modelPLS(i).Yhat).^2);
    modelPLS(i).R2       = 1 - modelPLS(i).RSS/modelPLS(i).TSS;

    %Q2
    modelPLS(i).PRESS    = sum((YVal - modelPLS(i).YPred).^2);
    modelPLS(i).Q2       = 1 - modelPLS(i).PRESS/modelPLS(i).TSS;

end

%%  Variance explained through line graph
figure;
plot(1:14,cumsum(100*modelPLS(14).var(2,:)),'-bo');
hold on
plot(1:14,cumsum(100*modelPLS(14).var(1,:)),'-ro');
xlabel('Number of PLS components');
ylabel('Percent Variance Explained');
legend(["Var Explained in Y", "Var Explained in X"]);
ylim([0 100])
xlim([1 14])

%% Varinace explained through bar charts
figure
subplot(2,1,1);
bar(modelPLS(14).var(end,:))
title("Explained Variance in Y");
xlabel("PC No.");
ylabel("Explained Variance");

subplot(2,1,2);
bar(modelPLS(14).var(1,:))
title("Explained Variance in X");
xlabel("PC No.");
ylabel("Explained Variance");

%% MSE chart
figure;
plot(modelPLS(14).MSE(end,:))
title("Mean Squared Error");
xlabel("No. PCs in model");
ylabel("Crossvalidation MSE");

%% R2
figure;
plot(1:14,[modelPLS(1:end).R2])
title("R2");
xlabel("No. Latent Variables");
ylabel("R2");

%% Q2
figure;
plot(1:14,[modelPLS(1:end).Q2])
title("Q2");
xlabel("No. Latent Variables");
ylabel("Q2");

%% PRESS
figure;
plot(1:14,[modelPLS(1:end).PRESS])
title("PRESS");
xlabel("No. Latent Variables");
ylabel("PRESS");

%% Prediction on the test data 
% We chose three LVs for the model
figure;
subplot(2,1,1);
bar(modelPLS(14).beta(2:end,1));
title("Regression coefficients of the model with 14 LVs");

subplot(2,1,2);
bar(modelPLS(3).beta(2:end,1));
title("Regression coefficients of the model with 3 LVs");
%% VIP Score to select the most important 
modelPLS(3).W0 = modelPLS(3).stats.W ./ sqrt(sum(modelPLS(3).stats.W.^2,1));
p              = size(modelPLS(3).P, 1);
sumSq          = sum(modelPLS(3).T.^2,1).*sum(modelPLS(3).Q.^2,1);
vipScore       = sqrt(p* sum(sumSq.*(modelPLS(3).W0.^2),2) ./ sum(sumSq,2));
indVIP         = find(vipScore >= 1);
namesVIPSensors = vars(indVIP);

figure;
scatter(1:length(vipScore),vipScore,'x')
hold on
scatter(indVIP,vipScore(indVIP),'rx')
plot([1 length(vipScore)],[1 1],'--k')
hold off
axis tight
xlabel('Predictor Variables')
ylabel('VIP Scores')

% Helpful note :  
% On the plot we see 9 variables above 1. These are the imp 
% variables required to predict RUL
% These variables are stored in the namesVIPSensors array

%% Plot Ypred against YValidation
V = [modelPLS(3).YPred YVal]
scatter(V(:,2),V(:,1))



