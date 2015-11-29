function avl_gui

% Remove existing figure (for debugging)
cf = findobj(0,'Type','Figure');
rm = strncmp(get(cf,'Name'),'MATLAB_AVL',10);
delete(cf(rm));

%% Container Setup
f = figure('Name','MATLAB_AVL_WRAPPER',...
    'Position',[100 100 900 600],...
    'NumberTitle', 'off');

% Tabs
handle.Tabs.Main = uix.TabPanel('Parent',f,'Padding',0);
handle.Tabs.Tab1 = uix.Panel('Parent',handle.Tabs.Main);
handle.Tabs.Tab2 = uix.Panel('Parent',handle.Tabs.Main);
handle.Tabs.Tab3= uix.Panel('Parent',handle.Tabs.Main);
handle.Tabs.Main.TabTitles = {'AVL_AEROGEN','AERO_DB_PLOT','DOS'};
handle.Tabs.Main.TabWidth = 100;
handle.Tabs.Main.Selection = 1;

% Flexible Horizontal Boxes
handle.HboxFlex.Main = uix.HBoxFlex('Parent',handle.Tabs.Tab1);
handle.HboxFlex.Panel1 = uix.Panel('Title','Setup','Parent',handle.HboxFlex.Main);
handle.HboxFlex.Panel2 = uix.Panel('Title','Execution','Parent',handle.HboxFlex.Main);
set(handle.HboxFlex.Main,'Widths',[-.7 -.3],'Spacing',5);

%% Col1
handle.Col1.VBox = uix.VBox('Parent',handle.HboxFlex.Panel1);

handle.Col1.Row1.Main = uix.HBox('Parent',handle.Col1.VBox);
handle.Col1.Row1.Text = uicontrol('Style','Text','String','AVL File:','Parent',handle.Col1.Row1.Main);
handle.Col1.Row1.Edit = uicontrol('Style','Edit','String','','Parent',handle.Col1.Row1.Main);
handle.Col1.Row1.Button = uicontrol('Style','PushButton','String','...:','Parent',handle.Col1.Row1.Main,'Callback',{@uigetfile_cb,handle.Col1.Row1.Text});

set(handle.Col1.Row1.Main,'Widths',[-.2 -.7 -.1],'Padding',0,'Spacing',5);

    function uigetfile_cb(src,evt,hdl)
        [filename, pathname] = uigetfile('*.avl', 'Select an .avl file');
        if isequal(filename,0)
            set(hdl,'String','User Cancelled Operation.')
        else
            set(hdl,'String',fullfile(pathname, filename));
        end
        
    end

handle.Col1.Row2.Main = uix.HBox('Parent',handle.Col1.VBox);
ax = axes('Parent',handle.Col1.Row2.Main);

t = 0:pi/50:5*pi;
st = sin(t);
ct = cos(t);
plot3(ax,st,ct,t)

handle.Col1.Row3.Radio.Main = uix.HButtonBox(...
    'Parent',handle.Col1.VBox,...
    'Padding',5,...
    'Spacing',5);

handle.Col1.Row3.Radio.Btn1 = uicontrol('String','FRONT','Parent',handle.Col1.Row3.Radio.Main,'Style','PushButton','Callback',{@BtnDnFcn,ax});
handle.Col1.Row3.Radio.Btn2 = uicontrol('String','TOP','Parent',handle.Col1.Row3.Radio.Main,'Style','PushButton','Callback',{@BtnDnFcn,ax});
handle.Col1.Row3.Radio.Btn3 = uicontrol('String','SIDE','Parent',handle.Col1.Row3.Radio.Main,'Style','PushButton','Callback',{@BtnDnFcn,ax});
handle.Col1.Row3.Radio.Btn4 = uicontrol('String','ISO','Parent',handle.Col1.Row3.Radio.Main,'Style','PushButton','Callback',{@BtnDnFcn,ax});

    function BtnDnFcn(src,evt,ax)
        view_sel = src.String;
        switch view_sel
            case 'TOP'
                view(ax,[0 0 1])
            case 'FRONT'
                view(ax,[1 0 0])
            case 'SIDE'
                view(ax,[0 -1 0])
            otherwise
                view(ax,[45 45])
        end
    end

set(handle.Col1.VBox,'Heights',[20 -1 40],'Padding',0,'Spacing',5);


%% Col2
handle.Col2.VBox = uix.VBox('Parent',handle.HboxFlex.Panel2);

handle.Col2.Row1.Main = uix.HBox('Parent',handle.Col2.VBox);
handle.Col2.Row1.Text = uicontrol('Style','Text','String','Alpha:','Parent',handle.Col2.Row1.Main);
handle.Col2.Row1.Edit = uicontrol('Style','Edit','String','min:step:max','Parent',handle.Col2.Row1.Main);

handle.Col2.Row2.Main = uix.HBox('Parent',handle.Col2.VBox);
handle.Col2.Row2.Text = uicontrol('Style','Text','String','Beta:','Parent',handle.Col2.Row2.Main);
handle.Col2.Row2.Edit = uicontrol('Style','Edit','String','min:step:max','Parent',handle.Col2.Row2.Main);

handle.Col2.Row3.Main = uix.HBox('Parent',handle.Col2.VBox);
handle.Col2.Row3.Text = uicontrol('Style','Text','String','Deflection:','Parent',handle.Col2.Row3.Main);
handle.Col2.Row3.Edit = uicontrol('Style','Edit','String','min:step:max','Parent',handle.Col2.Row3.Main);

handle.Col2.Row4.Main = uix.HBox('Parent',handle.Col2.VBox);
handle.Col2.Row4.Exec = uicontrol('Style','Frame','Parent',handle.Col2.Row4.Main);

set(handle.Col2.VBox,'Heights',[20 20 20 20],'Padding',10,'Spacing',5);
set(handle.Col2.Row1.Main,'Widths',[-.3 -.7]);
set(handle.Col2.Row2.Main,'Widths',[-.3 -.7]);
set(handle.Col2.Row3.Main,'Widths',[-.3 -.7]);


end



