function outstruct = cifti_read_metadata(metadata, niftihdr, filename, varargin)
    %function outstruct = cifti_read_metadata(filename, ...)
    %   Reads the metadata stored in the NIfTI image.
    %   Modified from cifti_read

    options = myargparse(varargin, {'wbcmd'});

    % --- check nifti header dimensions
    if niftihdr.dim(1) < 6 || any(niftihdr.dim(2:5) ~= 1)
        error(['wrong nifti dimensions for cifti file ' filename]);
    end

    % --- process CIFTI XML metadata
    try
        outstruct = cifti_parse_xml(metadata, filename);
    catch excinfo
        if strcmp(excinfo.identifier, 'cifti:version')
            error(['CIFTI file "' filename '" appears to not be version 2, please convert file using wb_command!']);
        end
        rethrow(excinfo);
    end

    % --- check dimensions

    dims_c = niftihdr.dim(6:(niftihdr.dim(1) + 1));  % extract cifti dimensions from header
    dims_m = dims_c([2 1 3:length(dims_c)]);         % for ciftiopen compatibility, first dimension for matlab code is down
    dims_xml = zeros(1, length(outstruct.diminfo));

    for i = 1:length(outstruct.diminfo)
        dims_xml(i) = outstruct.diminfo{i}.length;
    end

    if any(dims_m(:) ~= dims_xml(:))
        error(['XML dimensions disagree with nifti dimensions in cifti file ' filename '!']);
    end

    % --- check datatype

    switch niftihdr.datatype
        case 2
            intype = 'uint8';
            inbitpix = 8;
        case 4
            intype = 'int16';
            inbitpix = 16;
        case 8
            intype = 'int32';
            inbitpix = 32;
        case 16
            intype = 'float32';
            inbitpix = 32;
        case 64
            intype = 'float64';
            inbitpix = 64;
        case 256
            intype = 'int8';
            inbitpix = 8;
        case 512
            intype = 'uint16';
            inbitpix = 16;
        case 768
            intype = 'uint32';
            inbitpix = 32;
        case 1024
            intype = 'int64';
            inbitpix = 64;
        case 1280
            intype = 'uint64';
            inbitpix = 64;
        otherwise
            error(['Unsupported datatype ' num2str(niftihdr.datatype) ' for cifti file ' filename, '!']);
    end

    if niftihdr.bitpix ~= inbitpix
        warning(['Mismatch between datatype (' num2str(niftihdr.datatype) ') and bitpix (' num2str(niftihdr.bitpix) ') in CIFTI file ' filename '!']);
    end
