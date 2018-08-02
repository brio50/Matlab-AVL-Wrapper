function [status,cmdout] = avl(varargin)
% AVL  checks if AVL is installed, helps if it isn't, and calls it as desired
%
persistent avlPathExec

%% Input Handling
p = inputParser;
addOptional(p,'avl_file','',@ischar);
addOptional(p,'run_file','',@ischar);
addOptional(p,'mass_file','',@ischar);
addParameter(p,'cmd',0,@(x) x==1 || x==0);
addParameter(p,'echo',0,@(x) x==1 || x==0);
parse(p,varargin{:});

%% Verify
if isempty(avlPathExec)
    
    [status,cmdout] = system('which avl*');
    
    avlPath = '';
    avlExec = strtrim(cmdout);
    
    % if not found
    if isempty(cmdout)
        
        if ispc, cmdline = 'MSDOS'; else, cmdline = 'TERMINAL'; end
        answer = questdlg(...
            ['AVL not found in ' cmdline ', would you like me to install'...
            ' it for you, or would you like to point to a copy you''ve already'...
            ' downloaded?'],...
            'Is AVL installed?',...
            'Install AVL','Point to AVL','Cancel',[]);
        
        switch answer
            case 'Install AVL'
                disp([answer ', coming right up!'])
                install_avl;
            case 'Point to AVL'
                disp([answer ', coming right up!'])
                point_avl;                
        end
    else
        test_avl
    end
    
    if isempty(avlPathExec)
        error(['AVL not found, cannot continue. Download and install ' ...
            'manually from http://www.mit.edu/markdrelaisawesome']);
    end
end

%% Execute

if p.Results.echo
    echo = '-echo';
else
    echo = '';
end

if p.Results.cmd
    % feed a pre-formatted command.txt file
    [status,cmdout] = system([avlPathExec ' < ' p.Results.avl_file '&'],echo);
    
else
    % call AVL per documentation
    [status,cmdout] = system([avlPathExec p.Results.avl_file p.Results.run_file p.Results.mass_file],echo);
    
end

%evalin('base','!avl.exe < ..\tmp\command.txt');
%!avl < ../tmp/command.txt

%% SUBFUNCTIONS

    function point_avl
        [avlExec,avlPath] = uigetfile('*','Where is AVL located?',pwd);
        if isempty(avlPath)
            return
        end
        
        test_avl
    end


    function install_avl
        
        % 0. Make sure XQUARTZ is installed for unix systems
        
        if isunix
            [status,cmdout] = system('which xquartz');
            if isempty(cmdout)
                error(['XQUARTZ must be installed to run AVL. It provides' ...
                    ' ''X11'' windowing for AVL graphics not-native to this OS.'])
            end
        end
        
        % 1. Download from MIT to tempdir
        
        % TODO: maybe instead of tempdir, an assumed getenv('Downloads') area?
        if ispec
            url = 'http://  avl337_Win.zip';
            temp = fullfile(tempdir,'avl337_Win.zip');
        elseif isunix
            url = 'http://  avl335_MacOSX.zip';
            temp = fullfile(tempdir,'avl335_MacOSX.zip');
        end
        
        avlZip = websave(temp,url);
        
        % 2. Unzip within tempdir
        
        avlUnzip = unzip(avlZip,fileparts(temp));
        
        % 3. Install AVL (make globally available by command-line)
        
        src = fullfile(fileparts(temp),avlUnzip);
        
        % TODO: instead of dest='', maybe use getenv('bin')? so it can be used
        % across unix systems?
        
        if isunix
            dest = '/usr/local/bin';
            [status,cmdout] = system(['cp ' src ' ' dest]);
            
            if isempty(cmdout)
                error(['Could not copy ''%s'' to ''%s'' due to the following ' ...
                    'error %s\n . You probably need to open permissions to the destination'...
                    'with ''chmod 775 %s'' and try again. )'],src,dest,cmdout,dest);
            end
            
            % Make sure Matlab can find it too
            if contains(getenv('PATH'),'/usr/local/bin')
                setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
            end
        else
            dest = '';
            [status,cmdout] = system(['cp ' src ' ' dest]);
            
            if isempty(cmdout)
            end
        end
        
        % 4. Prove it
        [status,cmdout] = test_avl;

    end

    function [status,cmdout] = test_avl
    
        avlPathExec = strtrim(fullfile(avlPath,avlExec));
        
        tempCmd = fullfile(pwd,'tmp','command.txt');
        tempOut = fullfile(pwd,'tmp','output.txt');

        fid = fopen(tempCmd,'w');
        fprintf(fid,'quit');
        fclose(fid);
        
        % check to see if indeed AVL executable
        status = system([avlPathExec ' <  ' tempCmd ' > ' tempOut],'-echo'); %[status,result]= won't work here
        
        keyboard
        fid = fopen(tempOut,'r');
        fread(fid,'%s\n');
        fclose(fid);
        
        cmdout = avlPathExec;
    end

end