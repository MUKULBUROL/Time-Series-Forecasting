clc
clear
close all

%% AR MODEL
% Load your time series data into a variable, assuming 'data' is your data.
% Replace 'data' with your actual data.
data = readtable('Cluster_Data_Team9_HDBSCAN.xlsx');

time_series_data = data{:, 3}; % Replace 'YourColumnName' with the actual column name

% Split the data into training and testing portions.
% Example of random 70/30 split
testing_proportion = 0.3;
testing_size = round(testing_proportion * height(time_series_data));
testing_indices = randperm(length(time_series_data), testing_size);

% Extract rows from the table using the row subscript and ':'
testing_data = data(testing_indices, :);
training_data = data(setdiff(1:height(time_series_data), testing_indices), :);

% Convert the data to an IDDATA object with 'seconds' as the TimeUnit
iddata_training = iddata(time_series_data, [], 'TimeUnit', 'seconds'); 

% Set autoregressive order (p)
p = 1;

% Fit autoregressive model
mdl = ar(iddata_training, p);

% Define the forecasting horizon
n_forecast_steps = testing_size;

% Forecast using the estimated model
forecasts = forecast(mdl, iddata_training, n_forecast_steps);

% Display the forecasted values
disp(forecasts);

figure(1);
plot(time_series_data, 'b', 'DisplayName', 'Actual Data');
hold on;

% Plot the actual data
figure(2); % Use a different figure number to avoid overwriting previous plots
plot(data.(2), data.(3), 'b', 'DisplayName', 'Actual Data');
hold on;

% Make predictions for the forecasting period using the AR model
ar_forecasts = forecast(mdl, iddata_training, n_forecast_steps);

% Extract the forecasted output data from the AR model
ar_forecast_data = ar_forecasts.OutputData;

% Plot the forecasted values from the AR model
ar_forecast_time = (1:n_forecast_steps);  % Time points for the AR forecast
plot(ar_forecast_time, ar_forecast_data, 'g', 'DisplayName', 'Forecast (AR Model)');


xlabel('Time'); % Customize the labels as needed
ylabel('Value');
legend('show');
title('AR and ODE Model Forecasts');



%% ODE MODEL

% Load your time series data into a variable, assuming 'data' is your data.
% Replace 'data' with your actual data.

% Define the ODE function with a different parameter name (e.g., 'growth_rate')
growth_rate = 0.1;  % Adjust the growth rate as needed
odefun = @(t, y) growth_rate * y;

% Define the time span over which you want to forecast
tspan = 1:height(data) + n_forecast_steps; % Adjust the time span

% Extract the first data point as the initial condition
y0 = table2array(data(1, :))';  % Convert the first row of the table to a column vector

% Solve the ODE using the built-in ODE solver
[t, y] = ode45(odefun, tspan, y0);

% Make predictions for the forecasting period
n_forecast_steps = 10; % Replace with the number of steps you want to forecast
predictions = y(end) * exp(growth_rate * (1:n_forecast_steps));

% Plot the actual data
figure(3); % Use a different figure number to avoid overwriting previous plots
plot(data.(2), data.(3), 'b', 'DisplayName', 'Actual Data');
hold on;

% Plot the forecasted values from the ODE model
forecast_time = t(end) + (1:n_forecast_steps);  % Time points for the forecast
plot(forecast_time, predictions, 'r', 'DisplayName', 'Forecast (ODE Model)');
xlabel('Time'); % Customize the labels as needed
ylabel('Value');
legend('show');
title('ODE Model Forecast');
