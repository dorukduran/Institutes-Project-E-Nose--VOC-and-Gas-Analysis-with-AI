% Combine separate MATLAB data files into a single file

% Directory containing the data files
data_dir = 'C:\Users\ASUS\OneDrive - Students RWTH Aachen University\Masaüstü\data from previous team\Propanol_28_03_2023\Open_Closed_Open'; % Change this to the path where your data files are located

% List of data files
data_files = {'Humidity.mat', 'NOX.mat', 'Temperature.mat', 'TGS2600.mat', 'TGS2602.mat', ...
              'TGS2610.mat', 'TGS2611.mat', 'TGS2620.mat', 'VOC.mat'};

% Initialize an empty structure to hold all the data
combined_data = struct();

% Load each data file and add its content to the combined_data structure
for i = 1:length(data_files)
    % Load the current data file
    file_path = fullfile(data_dir, data_files{i});
    data = load(file_path);
    
    % Get the variable name dynamically
    var_names = fieldnames(data);
    if length(var_names) ~= 1
        error('The file %s does not contain exactly one variable.', data_files{i});
    end
    var_name = var_names{1};
    
    % Add the data to the combined_data structure
    combined_data.(var_name) = data.(var_name);
end

% Save the combined data into a new MATLAB file
save('combined_data.mat', '-struct', 'combined_data');

disp('Data files have been combined and saved to combined_data.mat');
