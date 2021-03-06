function compile_function(func_name,program_name,additional_folders,exit_on_fail)

    if nargin < 3
        additional_folders = {};
    elseif ~iscell(additional_folders)
        additional_folders = {additional_folders};
    end
    
    if nargin < 4
        % If we are running headless, exit on error
        exit_on_fail = ~usejava('desktop');
    end
    
    if exit_on_fail
        try
            run()
        catch e
            disp(getReport(e));
            exit(1)
        end
    else
        run();
    end
    
    function run()

        % Get version
        [ver,is_release] = get_git_version();

        % Build App
        if exist(['.' filesep 'build'],'dir')
            rmdir('build','s');
        end

        mkdir('build');
        delete(['build' filesep '*']);

        args = {'-m',func_name, '-v', '-d', 'build', '-o', program_name};
        for i=1:length(additional_folders)
            args = [args {'-a' additional_folders{i}}];
        end

        mcc(args{:});

        if ispc
            ext = '.exe';
        else
            ext = '.app';
        end

        new_file = [program_name ' ' ver ' ' computer('arch')];
        movefile(['build' filesep program_name ext], ['build' filesep new_file ext]);
        
        % Bundle file
        if ismac
            mkdir(['build' filesep 'dist']);
            movefile(['build' filesep new_file ext], ['build' filesep 'dist' filesep new_file ext]);
            cmd = ['hdiutil create "./build/' new_file '.dmg" -srcfolder ./build/dist/ -volname "' new_file '" -ov'];
            system(cmd)
            final_file = ['build/' new_file '.dmg'];
        else
            final_file = ['build' filesep new_file ext];
        end

        if is_release
            dir1 = 'release';
        else 
            dir1 = 'latest';
        end
        mkdir(['build' filesep dir1]);
        mkdir(['build' filesep dir1 filesep ver]);

        movefile(final_file, ['build' filesep dir1 filesep ver]);
    end
end