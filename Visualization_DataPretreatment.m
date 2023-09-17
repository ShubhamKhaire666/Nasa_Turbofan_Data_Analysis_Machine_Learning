clc 
clear all
close all

M = readmatrix('data/RUL_FD001.txt');

Test = readmatrix('data/test_FD001.txt');

Train = readmatrix('data/train_FD001.txt');

%% Check if there are any zero values in the datasets
% Create a logical matrix where 'true' represents zero values.
zeroMatrix = (Test == 0);

% Count the number of zero values in each column (variable).
zeroCountPerColumn = sum(zeroMatrix);

% Count the total number of zero values in the entire matrix.
totalZeroCount = sum(zeroCountPerColumn);

% Display the results
disp('Zero count per column:');
disp(zeroCountPerColumn);

disp(['Total zero count in the matrix: ', num2str(totalZeroCount)]);


%% Check if there are any NaN/Null values in the dataset

% % Create a logical matrix where 'true' represents NaN values.
% nanMatrix = isnan(Train);
% 
% % Count the number of NaN values in each column (variable).
% nanCountPerColumn = sum(nanMatrix);
% 
% % Count the total number of NaN values in the entire matrix.
% totalNaNCount = sum(nanCountPerColumn);
% 
% % Display the results
% disp('NaN count per column:');
% disp(nanCountPerColumn);
% 
% disp(['Total NaN count in the matrix: ', num2str(totalNaNCount)]);

%% Visualizations


% Assuming you have a matrix 'M' with 26 columns.
% Create a table and assign your data to it.
T = array2table(Train);

% Define the new column names (26 names in this example).
newColumnNames = {'unit number', 'time, in cycles', 'operational setting 1', ...
    'operational setting 2', 'operational setting 3', 'sensor measurement 1', ...
    'sensor measurement 2', 'sensor measurement 3', 'sensor measurement 4', ...
    'sensor measurement 5', 'sensor measurement 6', 'sensor measurement 7', ...
    'sensor measurement 8', 'sensor measurement 9', 'sensor measurement 10', ...
    'sensor measurement 11', 'sensor measurement 12', 'sensor measurement 13', ...
    'sensor measurement 14', 'sensor measurement 15', 'sensor measurement 16', ...
    'sensor measurement 17', 'sensor measurement 18', 'sensor measurement 19', ...
    'sensor measurement 20', 'sensor measurement 21'};

% Now, set the column names directly using the VariableNames property.
if size(newColumnNames, 2) == size(T, 2)
    T.Properties.VariableNames = newColumnNames;
else
    disp('Number of column names does not match the number of columns in the matrix.');
end

summary(T)


% Plot histograms for selected variables (e.g., sensor measurements)
subplot(3, 1, 1);
histogram(Train(:, 3));  
title('Histogram of Operational Setting 1');

subplot(3, 1, 2);
histogram(Train(:, 4));  
title('Histogram of Operational Setting 2');

subplot(3, 1, 3);
histogram(Train(:, 5));  
title('Histogram of Operational Setting 3');

%% Visualization Sensor over time

figure
subplot(2,2,1)
hold on

for i = 1:100
    time = Train(:, 1) == i;
    resultingRows = Train(time, :);
    
    plot(resultingRows(:,13));
    title('Sensor Number 8 Measurement  Over Time');
    xlabel('Time');
    ylabel('Sensor Value');

end

hold off


subplot(2,2,2)
hold on

for i = 1:100
    time = Train(:, 1) == i;
    resultingRows = Train(time, :);
    
    plot(resultingRows(:,17));
    title('Sensor Number 12 Measurement  Over Time');
    xlabel('Time');
    ylabel('Sensor Value');

end

hold off


subplot(2,2,3)

hold on

for i = 1:100
    time = Train(:, 1) == i;
    resultingRows = Train(time, :);
    
    plot(resultingRows(:,19));
    title('Sensor Number 14 Measurement  Over Time');
    xlabel('Time');
    ylabel('Sensor Value');

end

hold off



subplot(2,2,4)
hold on

for i = 1:100
    time = Train(:, 1) == i;
    resultingRows = Train(time, :);
    
    plot(resultingRows(:,24));
    title('Sensor Number 19 Measurement  Over Time');
    xlabel('Time');
    ylabel('Sensor Value');

end

hold off

%% Visualization Number data per engine

for i = 1:100
    time = Train(:, 1) == i;
    Number_Of_Values_Per_Engine(1,i) = sum(time);
end

figure
bar(Number_Of_Values_Per_Engine);
xlabel('Engine Number');
ylabel('Number of values')
title('Number of values per Engine')
grid on


% % Sample data
% x = [1, 2, 3, 4, 5];
% y = [10, 15, 7, 12, 9];
% 
% % Create a bar plot
% bar(x, y);
% 
% % Add labels and a title
% xlabel('X-axis');
% ylabel('Y-axis');
% title('Bar Plot Example');
% 
% % Add grid lines (optional)
% grid on;
% 
% % You can also customize the appearance of the bars, such as color and width, if needed.
% % For example:
% % bar(x, y, 'b', 'LineWidth', 2);
