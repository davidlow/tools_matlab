classdef LoggableObj < handle % {

properties (Access = public)
    notes   % NOTES to save
    p       % Parameters to save
end

properties (Access = protected)
    git
    namestring
    savedir
end

methods (Access = public)% {

    function this = LoggableObj(name, savedirectory)
        this.git   = '';
        this.notes = '';
        this.namestring = name;
        this.savedir = savedirectory;
    end

    function delete(this)
        clear git;
        clear notes;
        clear p;
        clear namestring;
        clear savedir;
    end

end 

methods (Access = protected)

    function filename = saveparams(this, keys)
        this.populategit();
        parameters = struct(namestring, struct());
        keys = [keys, 'git', 'namestring', 'notes', 'p'];
        for i = 1:length(keys)
            parameters.(nameestring).(keys{i}) = this.(keys{i});
        end
        filename = [this.savedir, this.paramstring()];
        save(filename, '-struct', 'parameters');
    end

    function filename = savedata(this, datamatrix);
        filename = [this.savedir, this.datastring()];
        csvwrite(filename, datamatrix);
    end

end 

methods (Access = private)
    function datastr = datastring(this)
        datastr = [this.timestring, '_', 
                   this.namestring, '_',
                   'data.csv'];
    end

    function paramstr = paramstring()
        paramstr = [this.timestring, '_',
                    this.namestring, '_',
                    '_params.mat'];
    end

    function str = timestring(this)
        timestr = char(datetime('now','TimeZone','local','Format',...
                                'yyyyMMdd_HH:mm:ss_z'));
    end

    function populategit(this)
        try 
            this.git = [system('git rev-parse HEAD'), '\n', ... 
                        system('git status -s')];
        catch ME
            this.git = 'No git or improperly installed';
        end 
    end

end % }end private methods

end % }end of classdef
