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

% Collect all of the aerodynamic table fieldnames
aeroFieldNames = fieldnames(data); 
isCoef = ~cellfun('isempty',regexp(aeroFieldNames,'^C','match'));
aeroFieldNames = aeroFieldNames(isCoef);

% Delete Cref from coefNames list, it's not a coefficient
if strcmp(aeroFieldNames{1},'Cref')
    aeroFieldNames(1) = []; 
end

isCtrlCoef = ~cellfun('isempty',regexp(aeroFieldNames,'_d\d_','match'));
aeroCtrlFieldNames = aeroFieldNames(isCtrlCoef);

isCLtot = ~cellfun('isempty',regexp(aeroCtrlFieldNames,'CLtot','match'));
zbp_name = strrep(aeroCtrlFieldNames(isCLtot),'CLtot_','');

isStabCoef = cellfun('isempty',regexp(aeroFieldNames,'_d\d_','match'));
aeroStabFieldNames = aeroFieldNames(isStabCoef);

%% PLOT Stability Coefs
fig = figure('Color',[1 1 1]);
n = 2;
m = 3;

for iSub = 1:m*n
    ax(iSub) = subplot(n,m,iSub);
    
    h(iSub) = surf( data.(aeroStabFieldNames{iSub}).xbp_data,...
                    data.(aeroStabFieldNames{iSub}).ybp_data,...
                    data.(aeroStabFieldNames{iSub}).data');
                
    xlabel(data.(aeroStabFieldNames{iSub}).xbp_name,'Interpreter','none');
    ylabel(data.(aeroStabFieldNames{iSub}).ybp_name,'Interpreter','none');
    zlabel(aeroStabFieldNames{iSub},'Interpreter','none')
   
    axis tight
end

%GOAL: allow selectable (in)dependent vars
%GOAL: link all axes
%GOAL: allow dropdown dependent var selection
%GOAL: view incremental 
%GOAL: 2D and 3D options: alpha, beta, defl

set(ax,'View',[-37.5,30])

% Link 3D Rotation
% hlink = linkprop(ax,{'CameraPosition','CameraUpVector'});
% key = 'graphics_linkprop';
% % Store link object on first subplot axes
% setappdata(fig,key,hlink);

%% PLOT Control Coefs for one Sideslip

n = 2;
m = 2;

beta = 0;
b0 = find(data.CLtot_d1_flap.zbp_data==beta);

for iCoef = 1:length(aeroStabFieldNames)
    
    fig = figure('Color',[1 1 1],'Name',[aeroStabFieldNames{iCoef} ' - BETA = ' num2str(beta)]);
    
    for iSurf = 1:length(zbp_name)
        
        ax(iSurf) = subplot(n,m,iSurf);
        
        h(iSurf) = surf(    data.([aeroStabFieldNames{iCoef} '_' zbp_name{iSurf}]).xbp_data,...
                            data.([aeroStabFieldNames{iCoef} '_' zbp_name{iSurf}]).zbp_data,...
                            squeeze(data.([aeroStabFieldNames{iCoef} '_' zbp_name{iSurf}]).data(:,b0,:))');
        
        xlabel(data.([aeroStabFieldNames{iCoef} '_' zbp_name{iSurf}]).xbp_name,'Interpreter','none');
        ylabel(data.([aeroStabFieldNames{iCoef} '_' zbp_name{iSurf}]).zbp_name,'Interpreter','none');
        zlabel([aeroStabFieldNames{iCoef} '_' zbp_name{iSurf}],'Interpreter','none')
        
        axis tight
    end
    
    set(ax,'View',[-37.5,30])
    
end


end