% Gas Detection and Analysis with Machine Learning
% This script loads sensor data, extracts features, trains a model, and evaluates it.

global experiment_files experiment_descriptions sensor_names time_start time_end sampling_interval smoothing_window features gas_labels gas_rf_model numTrees

% Data files and experiment descriptions
experiment_files_ethanol = {'Ethanol_1-5-5_Open-Closed-Open_Valve.mat', 'Ethanol_3-5-5_Open-Closed-Open_Valve.mat', 'Ethanol_2-5-5_Open-Closed-Open_Valve.mat', 'Ethanol_syringe_StepMeasurement.mat'};
experiment_descriptions_ethanol = {'1-5-5 Ethanol Open-Closed-Open', '3-5-5 Ethanol Open-Closed-Open', '2-5-5 Ethanol Open-Closed-Open', 'Ethanol Injected with a syringe - Step measurement'};

experiment_files_isopropanol = {'Isopropanol_1-5-2_Open-Closed-Open.mat', 'Isopropanol_StepMeasurement.mat'};
experiment_descriptions_isopropanol = {'1-5-2 Isopropanol Open-Closed-Open', 'Isopropanol Step Measurement'};

experiment_files_acetone = {'Acetone_1-2-5-4_Open-Closed-Open.mat', 'Acetone_StepMeasurement.mat'};
experiment_descriptions_acetone = {'1-2-5-4 Acetone Open-Closed-Open', 'Acetone Step Measurement'};

% Combine files and descriptions for single gas experiments
experiment_files = [experiment_files_ethanol, experiment_files_isopropanol, experiment_files_acetone];
experiment_descriptions = [experiment_descriptions_ethanol, experiment_descriptions_isopropanol, experiment_descriptions_acetone];
sensor_names = {'adc_TGS2600', 'adc_TGS2602', 'adc_TGS2610', 'adc_TGS2611', 'adc_TGS2620', 'humidity', 'temperature', 'NOX', 'VOC'};

% Time series parameters
time_start = 1;
time_end = 250;
sampling_interval = 5; % In seconds
smoothing_window = 2; % Data smoothing window size 

% Load and prepare the data
[features, gas_labels] = load_and_prepare_data(experiment_files, experiment_descriptions, time_start, time_end, sampling_interval, smoothing_window);

% Check if there are any saved model data
if isfile('model_data.mat')
    load('model_data.mat', 'features', 'gas_labels');
end

% Split the data into training and test sets
cv = cvpartition(gas_labels, 'HoldOut', 0.3);
train_features = features(training(cv), :);
train_gas_labels = gas_labels(training(cv), :);
test_features = features(test(cv), :);
test_gas_labels = gas_labels(test(cv), :);

% Train the Random Forest model (Gas Type Prediction)
numTrees = 100;
gas_rf_model = TreeBagger(numTrees, train_features, train_gas_labels, 'Method', 'classification');

% Evaluate the model (Gas Type Prediction)
gas_predictions = predict(gas_rf_model, test_features);
gas_predictions = str2double(gas_predictions); % Convert to double if returned as string
gas_accuracy = sum(gas_predictions == test_gas_labels) / length(test_gas_labels);
gas_conf_mat = confusionmat(test_gas_labels, gas_predictions);

% Display the initial accuracy in a separate message box
accuracy_message = sprintf('Gas Type Prediction Model Accuracy: %.2f%%', gas_accuracy * 100);
msgbox(accuracy_message, 'Model Accuracy');

% Create the GUI
fig = uifigure('Name', 'Gas Detection and Analysis');
uilabel(fig, 'Position', [20 370 400 22], 'Text', 'Select an option:');
optionList = uilistbox(fig, 'Position', [20 250 400 100], 'Items', {'1: Select from available files', '2: Upload new data', '3: Upload and label new data'});
uibutton(fig, 'Position', [20 200 400 30], 'Text', 'Confirm', 'ButtonPushedFcn', @(btn,event) processChoice(optionList.Value));

% Function to process user choice
function processChoice(choice)
    global experiment_files experiment_descriptions gas_rf_model time_start time_end sampling_interval smoothing_window features gas_labels numTrees
    switch choice
        case '1: Select from available files'
            selectFileForAnalysis();
        case '2: Upload new data'
            [file_name, experiment_description] = upload_new_data();
            analyze_selected_file(file_name, experiment_description, gas_rf_model, time_start, time_end, sampling_interval, smoothing_window, true);
        case '3: Upload and label new data'
            upload_and_label_new_data_gui();
        otherwise
            msgbox('Invalid choice.');
    end
end

% Function to select file for analysis
function selectFileForAnalysis()
    global experiment_files experiment_descriptions gas_rf_model time_start time_end sampling_interval smoothing_window
    file_list = cellfun(@(x,y) sprintf('%s: %s', num2str(x), y), num2cell(1:length(experiment_files)), experiment_files, 'UniformOutput', false);
    fig2 = uifigure('Name', 'Select File for Analysis');
    lstbox = uilistbox(fig2, 'Position', [20 200 400 200], 'Items', file_list);
    uibutton(fig2, 'Position', [20 150 400 30], 'Text', 'Analyze', 'ButtonPushedFcn', @(btn,event) analyzeFile(lstbox));
end

% Function to analyze the selected file
function analyzeFile(lstbox)
    global experiment_files experiment_descriptions gas_rf_model time_start time_end sampling_interval smoothing_window
    file_index = str2double(regexp(lstbox.Value, '^\d+', 'match', 'once'));
    analyze_selected_file(experiment_files{file_index}, experiment_descriptions{file_index}, gas_rf_model, time_start, time_end, sampling_interval, smoothing_window, false);
end

% Function to upload new data
function [file_name, experiment_description] = upload_new_data()
    [file_name, path] = uigetfile('*.mat', 'Select the MATLAB data file');
    if isequal(file_name, 0)
        disp('No file selected.');
        file_name = '';
        path = '';
        experiment_description = '';
        return;
    end
    file_name = fullfile(path, file_name);
    experiment_description = input('Please enter the experiment description: ', 's');
end

% Function to upload and label new data with GUI
function upload_and_label_new_data_gui()
    fig3 = uifigure('Name', 'Upload and Label New Data');
    uilabel(fig3, 'Position', [20 300 400 22], 'Text', 'Select the MATLAB data file:');
    uploadButton = uibutton(fig3, 'Position', [20 250 400 30], 'Text', 'Upload File', 'ButtonPushedFcn', @(btn,event) selectFile());
    uilabel(fig3, 'Position', [20 200 400 22], 'Text', 'Enter experiment description:');
    descriptionField = uitextarea(fig3, 'Position', [20 150 400 30]);
    uilabel(fig3, 'Position', [20 100 400 22], 'Text', 'Enter gas label (1: Ethanol, 2: Isopropanol, 3: Acetone, 4: Other):');
    gasLabelField = uitextarea(fig3, 'Position', [20 50 400 30]);
    uibutton(fig3, 'Position', [20 10 400 30], 'Text', 'Submit', 'ButtonPushedFcn', @(btn,event) submitData(descriptionField.Value, str2double(gasLabelField.Value)));

    function selectFile()
        [file_name, path] = uigetfile('*.mat', 'Select the MATLAB data file');
        if isequal(file_name, 0)
            disp('No file selected.');
            return;
        end
        assignin('base', 'uploaded_file', fullfile(path, file_name));
    end

    function submitData(description, gas_label)
        global time_start time_end sampling_interval smoothing_window features gas_labels gas_rf_model numTrees
        file_name = evalin('base', 'uploaded_file');
        if isempty(file_name)
            msgbox('No file uploaded.');
            return;
        end
        if isempty(description) || isempty(gas_label)
            msgbox('Please fill in all fields.');
            return;
        end
        if gas_label < 1 || gas_label > 4
            msgbox('Invalid label. Please enter 1, 2, 3, or 4.');
            return;
        end
        [new_features, ~] = load_and_prepare_data({file_name}, {description}, time_start, time_end, sampling_interval, smoothing_window);
        features = [features; new_features];
        gas_labels = [gas_labels; repmat(gas_label, size(new_features, 1), 1)];
        gas_rf_model = TreeBagger(numTrees, features, gas_labels, 'Method', 'classification');
        save('model_data.mat', 'features', 'gas_labels');
        msgbox('The model has been updated with new labeled data.');
    end
end

% Function to analyze the selected data file and predict the gas type
function analyze_selected_file(file_name, experiment_description, gas_rf_model, time_start, time_end, sampling_interval, smoothing_window, is_new_data)
    global features gas_labels
    % Load and prepare the data
    [features, gas_labels] = load_and_prepare_data({file_name}, {experiment_description}, time_start, time_end, sampling_interval, smoothing_window);

    % Predict the gas type
    gas_predictions = predict(gas_rf_model, features);
    gas_predictions = str2double(gas_predictions); % Convert to double if returned as string
    
    % Prepare the results for display in a separate window
    results_str = '';
    if ~is_new_data
        gas_accuracy = sum(gas_predictions == gas_labels) / length(gas_labels);
        results_str = sprintf('Gas Type Prediction Accuracy for %s: %.2f%%\n', file_name, gas_accuracy * 100);
        % Display the prediction results
        for i = 1:length(gas_predictions)
            results_str = sprintf('%sPredicted: Gas type: %s. / Actual: Gas type: %s\n', results_str, ...
                gas_label_to_string(gas_predictions(i)), gas_label_to_string(gas_labels(i)));
        end
    else
        % Display only predicted results for new data
        for i = 1:length(gas_predictions)
            results_str = sprintf('%sPredicted: Gas type: %s.\n', results_str, gas_label_to_string(gas_predictions(i)));
        end
    end
    
    % Display the results in a message box
    msgbox(results_str, 'Gas Type Prediction Results');
end

% Function to convert gas label to string
function gas_type = gas_label_to_string(label)
    if label == 1
        gas_type = 'Ethanol';
    elseif label == 2
        gas_type = 'Isopropanol';
    elseif label == 3
        gas_type = 'Acetone';
    elseif label == 4
        gas_type = 'Other';
    else
        gas_type = 'Unknown';
    end
end

% Data Loading and Preparation Function
function [features, gas_labels] = load_and_prepare_data(file_list, experiment_descriptions, time_start, time_end, sampling_interval, smoothing_window)
    num_files = length(file_list);
    all_features = [];
    all_gas_labels = [];
    
    for i = 1:num_files
        data = load(file_list{i});
        sensors = fieldnames(data);
        num_sensors = length(sensors);
        
        for j = 1:num_sensors
            sensor_data = data.(sensors{j});
            if length(sensor_data) < time_end
                continue;
            end
            
            sensor_data = sensor_data(time_start:time_end);
            smoothed_data = smooth_data(sensor_data, smoothing_window);
            
            % Feature extraction
            mean_value = mean(smoothed_data);
            max_value = max(smoothed_data);
            min_value = min(smoothed_data);
            std_value = std(smoothed_data);
            median_value = median(smoothed_data);
            skewness_value = skewness(smoothed_data);
            kurtosis_value = kurtosis(smoothed_data);
            
            % Features
            feature = [mean_value, max_value, min_value, std_value, median_value, skewness_value, kurtosis_value];
            all_features = [all_features; feature];
            
            % Gas type labels
            if contains(experiment_descriptions{i}, 'Ethanol')
                gas_label = 1; % Ethanol
            elseif contains(experiment_descriptions{i}, 'Isopropanol')
                gas_label = 2; % Isopropanol
            elseif contains(experiment_descriptions{i}, 'Acetone')
                gas_label = 3; % Acetone
            else
                gas_label = 4; % Other
            end
            
            all_gas_labels = [all_gas_labels; gas_label];
        end
    end
    
    features = all_features;
    gas_labels = all_gas_labels;
end

% Data Smoothing Function
function smoothed_data = smooth_data(data, window_size)
    smoothed_data = sgolayfilt(data, 3, 2*window_size + 1);
end
