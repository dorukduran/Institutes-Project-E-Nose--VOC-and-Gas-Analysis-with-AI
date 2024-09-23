
% Experiment names and file paths
experiment_files = {'Ethanol_1-5-5_Open-Closed-Open_Valve.mat', 'Ethanol_3-5-5_Open-Closed-Open_Valve.mat', 'Ethanol_2-5-5_Open-Closed-Open_Valve.mat', 'Ethanol_syringe_StepMeasurement.mat'};
experiment_descriptions = {'Ethanol 1-5-5 Open-Closed-Open With Valve','Ethanol 3-5-5 Open-Closed-Open With Valve', 'Ethanol 2-5-5 Open-Closed-Open with Valve','Ethanol Injected with a syringe - Step measurement'};
sensor_names = {'adc_TGS2600', 'adc_TGS2602', 'adc_TGS2610', 'adc_TGS2611', 'adc_TGS2620', 'humidity', 'temperature', 'NOX', 'VOC'};
reaction_time_limits = [7, 12, 12, 11, 15] * 60; % Limits in minutes, converted to seconds
removal_time_limits = [8, 13, 13, 12, 16] * 60; % Limits in minutes, converted to seconds

% Time series parameters
time_start = 1;
time_end = 250;
sampling_interval = 5; % Sampling interval in seconds
threshold = 50; % Threshold value for slope changes
smoothing_window = 2; % Window size for data smoothing

% Loop through each experiment file
for exp_idx = 1:length(experiment_files)
    data = load_data(experiment_files{exp_idx});
    if isempty(data)
        disp(['Error loading data from file: ' experiment_files{exp_idx}]);
        continue;
    end
    create_plots(data, sensor_names, time_start, time_end, sampling_interval, exp_idx, experiment_descriptions{exp_idx}, smoothing_window);
    analyze_experiment(data, sensor_names, exp_idx, experiment_descriptions{exp_idx}, threshold, sampling_interval, smoothing_window, reaction_time_limits(exp_idx), removal_time_limits(exp_idx));
end

%% Functions

% Load data function
function data = load_data(filename)
    try
        s = warning('off', 'MATLAB:load:cannotInstantiateObj');
        data = load(filename);
        warning(s);
    catch ME
        data = [];
        disp(['Error loading file: ' filename]);
        disp(['Error message: ' ME.message]);
    end
end

% Create plots function
function create_plots(data, sensor_names, time_start, time_end, sampling_interval, exp_idx, experiment_description, smoothing_window)
    experiment_data = data;
    figure;
    num_sensors = length(sensor_names);
    
    for sensor_idx = 1:num_sensors
        sensor_name = sensor_names{sensor_idx};
        if isfield(experiment_data, sensor_name)
            sensor_readings = experiment_data.(sensor_name);
            if length(sensor_readings) < time_end
                disp(['Not enough data points for sensor: ' sensor_name]);
                continue;
            end
            sensor_readings = sensor_readings(time_start:time_end);
            smoothed_readings = smooth_data(sensor_readings, smoothing_window);
            time_scaled = (0:length(sensor_readings) - 1) * sampling_interval / 60; % Scale time series correctly
            slope = calculate_slope(smoothed_readings, sampling_interval);
            
            subplot(num_sensors, 2, 2 * sensor_idx - 1);
            plot(time_scaled, sensor_readings);
            title(['Sensor Readings for ' sensor_name]);
            xlabel('Time (minutes)');
            ylabel(sensor_name);
            
            subplot(num_sensors, 2, 2 * sensor_idx);
            plot(time_scaled, slope);
            title(['Slope of Sensor Readings for ' sensor_name]);
            xlabel('Time (minutes)');
            ylabel('Slope');
        else
            disp(['Sensor ' sensor_name ' not found in ' experiment_files{exp_idx}]);
        end
    end
    
    sgtitle(['Experiment ' num2str(exp_idx) ': ' experiment_description]);
end

% Main analysis function
function analyze_experiment(data, sensor_names, exp_idx, experiment_description, threshold, sampling_interval, smoothing_window, reaction_time_limit, removal_time_limit)
    % This function analyzes the data from an experiment, detecting significant changes in sensor readings.
    % It calculates gas application and removal times, and checks if these times exceed predefined limits.

    experiment_data = data;  % Load the experiment data
    num_sensors = length(sensor_names);  % Number of sensors in the experiment

    % Loop through each sensor for detailed analysis
    for sensor_idx = 1:num_sensors
        sensor_name = sensor_names{sensor_idx};  % Get the name of the current sensor
        if isfield(experiment_data, sensor_name)
            sensor_readings = experiment_data.(sensor_name);  % Get the readings for the current sensor
            time_series = create_time_series(sensor_readings, sampling_interval);  % Create the time series for the sensor data
            smoothed_readings = smooth_data(sensor_readings, smoothing_window);  % Smooth the sensor readings
            slope = calculate_slope(smoothed_readings, sampling_interval);  % Calculate the slope of the smoothed readings
            significant_changes = detect_significant_changes(slope, threshold);  % Detect significant changes in the slope

            % If there are significant changes, determine gas application and removal times
            if ~isempty(significant_changes)
                gas_application_idx = significant_changes(1);  % Index of the first significant change
                [gas_application_time, gas_removal_time] = detect_gas_times(slope, time_series, threshold, gas_application_idx);
                gas_application_duration = gas_removal_time - gas_application_time;  % Duration of gas application

                % Check if gas application time exceeds reaction time limit
                if gas_application_time > reaction_time_limit
                    display_results(exp_idx, experiment_description, sensor_name, 'No Reaction', 'No Reaction', 'No Reaction');
                else
                    % Check if gas removal time exceeds removal time limit
                    if gas_removal_time > removal_time_limit
                        display_results(exp_idx, experiment_description, sensor_name, gas_application_time, 'No Reaction', 'No Reaction');
                    else
                        % Display results in minutes and seconds
                        display_results(exp_idx, experiment_description, sensor_name, gas_application_time, gas_removal_time, gas_application_duration);
                    end
                end
            else
                disp(['No significant changes detected for sensor ' sensor_name ' in ' experiment_description]);
            end
        else
            disp(['Sensor ' sensor_name ' not found in ' experiment_description]);
        end
    end
end

%% Helper Functions

% Create time series function
function time_series = create_time_series(sensor_readings, sampling_interval)
    time_series = (0:length(sensor_readings) - 1) * sampling_interval; % Time series in seconds
end

% Data smoothing function
function smoothed_readings = smooth_data(sensor_readings, window_size)
    smoothed_readings = sgolayfilt(sensor_readings, 3, 2*window_size + 1); % Savitzky-Golay filter
end

% Slope calculation function
function slope = calculate_slope(sensor_readings, sampling_interval)
    time_series = (0:length(sensor_readings) - 1) * sampling_interval; % Time series in seconds
    slope = gradient(sensor_readings, time_series);
end

% Detect significant changes function
function significant_changes = detect_significant_changes(slope, threshold)
    significant_changes = find(abs(slope) > threshold);
end

% Detect gas application and removal times function
function [gas_application_time, gas_removal_time] = detect_gas_times(slope, time_series, threshold, gas_application_idx)
    positive_slope_changes = find(slope > threshold);
    gas_removal_idx = positive_slope_changes(find(positive_slope_changes > gas_application_idx, 1, 'first'));
    
    gas_application_time = time_series(gas_application_idx);
    gas_removal_time = time_series(gas_removal_idx);
end

% Calculate gas application time function
function gas_application_time = calculate_gas_application_time(significant_changes, slope, time_series, threshold)
    gas_application_idx = significant_changes(1);
    gas_application_time = time_series(gas_application_idx);
end

% Display results function
function display_results(exp_idx, experiment_description, sensor_name, gas_application_time, gas_removal_time, gas_application_duration)
    fprintf('Experiment %d: %s\n', exp_idx, experiment_description);
    fprintf('Sensor: %s\n', sensor_name);
    if ischar(gas_application_time)
        fprintf('Reaction Time: %s\n', gas_application_time);
    else
        fprintf('Reaction Time: %d minutes %d seconds\n', floor(gas_application_time/60), mod(gas_application_time, 60));
    end
    if ischar(gas_removal_time)
        fprintf('Gas Removal Time: %s\n', gas_removal_time);
    else
        fprintf('Gas Removal Time: %d minutes %d seconds\n', floor(gas_removal_time/60), mod(gas_removal_time, 60));
    end
    if ischar(gas_application_duration)
        fprintf('Gas Application Duration: %s\n\n', gas_application_duration);
    else
        fprintf('Gas Application Duration: %d minutes %d seconds\n\n', floor(gas_application_duration/60), mod(gas_application_duration, 60));
    end
end