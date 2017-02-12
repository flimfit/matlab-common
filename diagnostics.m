function diagnostics(event_category, event_label, varargin)
        
    if ~isdeployed
        return
    end

    try
        fid = fopen('GeneratedFiles/version.txt');
        ver = fgetl(fid);
        fclose(fid);

        if ~ispref('FLIMfit','UID')
            uid = dec2hex(randi(1e10));
            setpref('FLIMfit','UID',uid);
        end
        uid = getpref('FLIMfit','UID');
        data = ['v=1&t=event&tid=UA-72259304-2&cid=' uid '&ec=' event_category '&ea=' event_label '&el=' event_label];
        data = [data '&an=FLIMfit&av=' ver];

        for i=1:2:(length(varargin)-1)
           encoded_argument = char(java.net.URLEncoder.encode(varargin{i+1},'UTF-8'));
           data = [data '&' varargin{i} '=' encoded_argument]; 
        end
        
        webwrite('http://www.google-analytics.com/collect',data);
    catch e
        disp('Diagnostics error:')
        disp(e.message);
    end
        