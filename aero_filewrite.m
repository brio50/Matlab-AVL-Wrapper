function aero = aero_filewrite(varargin)
%AERO_FILEREAD
%   convert st file data into an aero structure/database suitable for
%   simulation look up tables
%
% 09/12/2014 - BB - Created

% Input Handling
if nargin == 0
    
    [file,path] = uigetfile({'*.mat','ST MAT-file'},'Select a .mat file that contains .st AVL output data!');
    
    if isequal(file,0)
        disp('User selected cancel.')
    else
        disp(['User selected ', fullfile(path, file)])
    end
    
    name = strrep(file,'.mat','');
    ext = '.mat';
    
    mat_file_write = 0;

elseif nargin <=3
    
    if isstruct(varargin{1})
        data = varargin{1};
    elseif exist(varargin{1},'file') == 2
        [path,name,ext] = fileparts(varargin{1});
    else
        error('Uncregonized input type or file does not exist.')
    end
    
    if nargin == 1
        mat_file_write = 0;  
    elseif nargin == 2
        mat_file_write = varargin{2};
    end
    
else
    
    error('Too many input arguments.');
    
end

% If a file was the input argument, load it!
if exist('ext','var') == 1
    load(fullfile(path,[name ext]));
    data = output;
    clear output
end

% Ensure that we're dealing with a .st mat-file
if ~isfield(data,'avl')
    error('The .mat file you''ve selected does not containt .avl data.');
else 
    if ~isfield(data.avl,'st')
        error('The .mat file you''ve selected does not containt .st data.');
    end
end

keyboard

for i = 1:length(data.avl.st)
    
end

for iCtrl = 1:length(ctrlNames)
    keyboard
    [ctrl.(ctrlNames{iCtrl}).data,m,n] = unique([data.avl.st.(ctrlNames{iCtrl})]);
    ctrl.(ctrlNames{iCtrl}).m = m;
    ctrl.(ctrlNames{iCtrl}).n = n;
end