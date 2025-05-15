
% Set up the Import Options and import the data
opts2 = delimitedTextImportOptions("NumVariables", 15);

% Specify range and delimiter
opts2.DataLines = [2, Inf];
opts2.Delimiter = ",";

% Specify column names and types
opts2.VariableNames = ["Var1", "Time", "Speed", "RPM", "nGear", "Throttle", "Brake", "DRS", "X", "Y", "Z", "Status", "Time1", "Status1", "Message"];
opts2.VariableTypes = ["double", "string", "double", "double", "double", "double", "categorical", "double", "double", "double", "double", "categorical", "string", "double", "categorical"];

% Specify file level properties
opts2.ExtraColumnsRule = "ignore";
opts2.EmptyLineRule = "read";

% Specify variable properties
opts2 = setvaropts(opts2, ["Time", "Time1"], "WhitespaceRule", "preserve");
opts2 = setvaropts(opts2, ["Time", "Brake", "Status", "Time1", "Message"], "EmptyFieldRule", "auto");

% Import the data
data = readtable("C:\Users\berke\OneDrive\Masaüstü\Performance Degradation Project\2023 Data\2023_RB_VER_1.csv", opts2);

% Clear temporary variables
clear opts2

% Display results
data
Converting Time Strings to Second Format
data = data(data.Time ~= "",:);
timeStr = data.Time;
% Split into 'days' and 'time' parts
parts = split(timeStr, " ");
days = str2double(parts(:, 1)); % Extract days as numeric
timePart = parts(:, 3); % Extract the 'hhmmss.SSSSSS' part
data.Time=datetime(timePart,'InputFormat','HH:mm:ss.SSSSSS','Format','HH:mm:ss.SSS');
% Extract hours, minutes, and seconds from datetime
hours = hour(data.Time); 
minutes = minute(data.Time); 
seconds = second(data.Time); 
timeInSeconds = hours * 3600 + minutes * 60 + seconds;
data.Time = timeInSeconds
%timeStr1 = data.Time1;
%parts = split(timeStr1, " ");
%days1 = str2double(parts(:, 1)); % Extract days as numeric
%timePart1 = parts(:, 3); % Extract the 'hhmmss.SSSSSS' part
%time1=second(datetime(timePart1,'InputFormat','HH:mm:ss.SSSSSS','Format','HH:mm:ss.SSS'));
%data.Time1=time1

% Data for full throttle (100%), No DRS and No Braking
allGasMask = (data.Throttle == 100) & (data.DRS ~=12) & (data.DRS ~=14) & (data.Brake == "False");
allGas = data(allGasMask, :)
plot(allGas.X,allGas.Time);
% Calculate Euclidean distance between consecutive points
distances = sqrt(diff(allGas.X).^2 + diff(allGas.Y).^2 + diff(allGas.Z).^2)
histogram(distances)
% Define a threshold for "straight-line zones" (e.g., small distances)
straightLineThreshold = 0.5; % Adjust based on your data scale
% Logical mask for identifying straight-line points
straightLineMask = [true; distances < straightLineThreshold]; % Include the first point
% Define a threshold for "straight-line zones" (e.g., small distances)
straightLineThreshold = 0.5; % Adjust this based on your data scale
% Initialize variables for zone labeling
zoneLabels = zeros(height(allGas), 1); % Preallocate for zone labels
currentZone = 1; % Start with the first zone
% Assign zone labels
zoneLabels(1) = currentZone; % First point is part of the first zone
for i = 2:height(allGas)
    if distances(i-1) < straightLineThreshold
        % If the distance is within the threshold, keep the same zone
        zoneLabels(i) = currentZone;
    else
        % Otherwise, start a new zone
        currentZone = currentZone + 1;
        zoneLabels(i) = currentZone;
    end
end
% Add the zone labels to the dataset
allGasData.Zone = zoneLabels;

