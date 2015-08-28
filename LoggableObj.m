classdef LoggableObj < handle & matlab.minin.CustomDisplay % {

properties (Access = public)
    notes   % NOTES to save
    p       % Parameters to save
end

properties (Access = protected)
    git
    namestring
end

methods (Access = public)% {

    function this = LoggableObj(name)
        git   = '';
        notes = '';
        namestring = name;
    end

    function delete(this)
        clear git;
        clear notes;
    end

end % }end public methods

methods (Access = protected)

    function saveparams(this, keys)
        this.populategit();
        parameters = struct(namestring, struct());
        keys = [keys, 'git', 'namestring', 'notes', 'p'];
        for i = 1:length(keys)
            parameters.(nameestring).(keys{i}) = this.(keys{i});
        end
        save(this.parameterstring(), '-struct', 'parameters');
    end

    function savedata  (this, datamatrix);
        csvwrite(this.datastring(), datamatrix);
    end

end % }end protected methods

methods (Access = private)
    function datastr = datastring(this)
        datastr = [this.timestring, '_', 
                   this.namestring, '_',
                   'data.csv'];
    end

    function paramstr = parameterstring()
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
