function aero_fileplot(varargin)
%ST_FILEPLOT
%   plot all of the .st data read by st_fileread.m
%
% 08/28/2014 - BB - Created

% Input Handling
if nargin == 0
    
    [file,path] = uigetfile({'*.mat','AERO MAT-file'},'Select a .mat file that contains AERO formatted data!');
    
    if isequal(file,0)
        disp('User selected cancel.')
    else
        disp(['User selected ', fullfile(pathname, filename)])
    end
    
    name = strrep(file,'.mat','');
    ext = '.mat';
    
elseif nargin == 1
    
    if isstruct(varargin{1})
        data = varargin{1};
    elseif exist(varargin{1},'file') == 2
        [path,name,ext] = fileparts(varargin{1});
    else
        error('Uncregonized input type or file does not exist.')
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

%% SORT 
varname = fieldnames(data.avl.st);

% CONTROL surface names appear between "e" and "CLa"
for iVar = 1:length(varname)
    if strcmp(varname{iVar},'e')
        i_start = iVar+1;
    elseif strcmp(varname{iVar},'CLa')
        i_end = iVar-1;
    end
end

ctrlNames = varname(i_start:i_end);

for iCtrl = 1:length(ctrlNames)
    [ctrl.(ctrlNames{iCtrl}).data,m,n] = unique([data.avl.st.(ctrlNames{iCtrl})]);
    ctrl.(ctrlNames{iCtrl}).m = m;
    ctrl.(ctrlNames{iCtrl}).n = n;
end

keyboard

for iA = 1:length(A)
   for iB = 1:length(B)
       for iD = 1:length(D)
       end
   end
end

%% PLOT
figure('Color',[1 1 1])
n = 2;
m = 3;

for iSub = 1:m*n
    ax(iSub) = subplot(n,m,1);
    
    h(iSub) = plot();
    
end

%GOAL: allow selectable (in)dependent vars
%GOAL: link all axes
%GOAL: allow dropdown dependent var selection
%GOAL: view incremental 
%GOAL: 2D and 3D options: alpha, beta, defl



end