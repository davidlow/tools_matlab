l = TestLoggableObj('test_LoggableObject', './testout/');
l.notes = 7;
l.p.param = 1;
l.p.lifeistough = 9e10;


data = [1,2,3; 4,5,6; 7,8,9];

paramname = l.saveparams(['newprop']);
savename  = l.savedata  (data       );

l.delete()

clearvars -except paramname savename

errors = 0;

load(paramname)
errors = 0;
ctr    = 1;

if(notes ~= 7)
    errors = bitor(errors, ctr);
end
ctr = bitshift(ctr,1);
if(p.param ~= 1)
    errors = bitor(errors, ctr);
end
ctr = bitshift(ctr,1);
if(p.lifeistough ~= 9e10)
    errors = bitor(errors, ctr);
end
ctr = bitshift(ctr,1);
if(newprop ~= 10)
    errors = bitor(errors, ctr);
end
ctr = bitshift(ctr,1);

data1 = csvread(savename);
if(sum(sum(data1 ~= [1,2,3;4,5,6;7,8,9])))
    errors = bitor(errors,ctr);
end
ctr = bitshift(ctr,1);

errors



classdef TestLoggableObj < LoggableObject

properties (Access = public)
    newprop 
end

methods (Access = public)
    function this = TestLoggableObj()
        this = this@LoggableObj('Test Object', './');
        newprop = 10;
    end

    function delete(this)
        this@delete();
        clear newprop
    end
end

end

