Lunit = 'Lunit'; %'m', 'ft', 'in'
Munit = 'Munit'; %'kg', 'lb'
Tunit = 'Tunit'; %'s'

str = '';
for iA = 1:nA
    for iB = 1:nB
        for iD = 1:nD
            str = sprintf('%s\n%s',str,' ---------------------------------------------');
            caseName = sprintf('a%i b%i d%i %i %i %i ', aSweep(iA), bSweep(iB), dSweep(iD),iA, iB, iD);
            str = sprintf('%s\n Run case  %i:  %s\n',str,sub2ind([nD,nB,nA],iD,iB,iA),caseName);
            str = sprintf('%s\n %-12s ->  %-11s =  %.5f',str,'alpha','alpha',aSweep(iA));
            str = sprintf('%s\n %-12s ->  %-11s =  %.5f',str,'beta' ,'beta' ,bSweep(iB));
            str = sprintf('%s\n %-12s ->  %-11s =  %.5f',str,'pb/2V','pb/2V',0);
            str = sprintf('%s\n %-12s ->  %-11s =  %.5f',str,'qc/2V','qc/2V',0);
            str = sprintf('%s\n %-12s ->  %-11s =  %.5f',str,'rb/2V','rb/2V',0);
            for iC = 1:length(ctrlNames)
                str = sprintf('%s\n %-12s ->  %-11s =  %.5f',str,ctrlNames{iC},ctrlNames{iC},0);
            end
            str = sprintf('%s\n ',str);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'alpha',0,'deg');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'beta' ,0,'deg');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'pb/2V',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'qc/2V',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'rb/2V',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'CL',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'CDo',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'bank',0,'deg');  
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'elevation',0,'deg');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'heading',0,'deg');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Mach',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'velocity',0,[Lunit '/' Tunit]);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'density',1,[Munit '/' Tunit '^3']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'grav.acc.',1,[Lunit '/' Tunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'turn_rad.',0,Lunit);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'load_fac.',1,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'X_cg',0,Lunit);              
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Y_cg',0,Lunit);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Z_cg',0,Lunit);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'mass',1,Munit);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Ixx',1,[Munit '-' Lunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Iyy',1,[Munit '-' Lunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Izz',1,[Munit '-' Lunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Ixy',0,[Munit '-' Lunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Iyz',0,[Munit '-' Lunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'Izx',0,[Munit '-' Lunit '^2']);
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'visc CL_a',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'visc CL_u',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'visc CM_a',0,'');
            str = sprintf('%s\n %-10s=   %.5f     %s',str,'visc CM_u',0,'');  
        end
    end
end