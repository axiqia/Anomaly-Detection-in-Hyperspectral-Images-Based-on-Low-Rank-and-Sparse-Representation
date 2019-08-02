function [data,param]=ReadHyperSpec(imgfilename)
%本函数读取img格式，前提是img图像显式带有'.img'后缀名。
if length(imgfilename)>=4
    switch strcmp(imgfilename(length(imgfilename)-3:end), '.img')
    case 0
        hdrfilename=strcat(imgfilename, '.hdr');
    case 1
        hdrfilename=strcat(imgfilename(1: (length(imgfilename)-4)), '.hdr');
    otherwise
        fprintf('Unknown FileType');
        exit();
    end
else
    hdrfilename=strcat(imgfilename, '.hdr');
end
%定义参数
param.lines = 0;
param.samples = 0;
param.bands = 0;

fidin=fopen(hdrfilename);

while ~feof(fidin)                                      % 判断是否为文件末尾               
    tword=fscanf(fidin,'%s/r/n');
    if strcmp(tword,'samples')                          % 得到列数
        fscanf(fidin,'%s/r/n');
        param.samples = str2double(fscanf(fidin,'%s/r/n'));
    end 
    if strcmp(tword,'lines')                            % 得到行数
        fscanf(fidin,'%s/r/n');
        param.lines = str2double(fscanf(fidin,'%s/r/n'));
    end 
    if strcmp(tword,'bands')                            % 得到波段数
        fscanf(fidin,'%s/r/n');
        param.bands = str2double(fscanf(fidin,'%s/r/n'));
    end 
    if strcmp(tword,'data')                             % 得到数据类型
        fscanf(fidin,'%s/r/n');
        fscanf(fidin,'%s/r/n');
        type = str2double(fscanf(fidin,'%s/r/n'));
        switch(type)
            case 1
                param.data_type = 'uint8';
                param.normalpar = 2^8-1;
            case 2
                param.data_type = 'int16';
                param.normalpar = 2^15-1;
            case 3
                param.data_type = 'int32';
                param.normalpar = 2^31-1;
            case 4
                param.data_type = 'float32';
                param.normalpar = 1;
            case 5
                param.data_type = 'double';
                param.normalpar = 1;
            case 12
                param.data_type = 'uint16';
                param.normalpar = 2^16-1;
            case 13
                param.data_type = 'uint32';
                param.normalpar = 2^32-1;
            otherwise
                fprintf('Unknown File Type :%d',type);
                exit();
        end
    end 
    if strcmp(tword,'interleave')                       % 得到格式
        fscanf(fidin,'%s/r/n');
        param.interleave = fscanf(fidin,'%s/r/n');
    end 
end 
fclose(fidin);
disp(param.lines);
disp(param.samples);
disp(param.bands);
%读取图像文件
data = multibandread(imgfilename ,[param.lines, param.samples, param.bands],param.data_type,0,param.interleave,'ieee-le',{'Band','Direct',1:1:param.bands});
data = double(data);
end

