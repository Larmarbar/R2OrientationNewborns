using QSM
using NIfTI

# In newborns 
const TEs = (0.0045, 0.010, 0.0155, 0.021, 0.0265)

# In adults 
const TEs = (0.006, 0.012, 0.018, 0.024, 0.030)


function run_r2star(path::AbstractString)
    if isdir(path)
        for (root, _, files) in walkdir(path)
            for file in files
                if endswith(file, ".nii.gz") || endswith(file, ".nii")
                    _run_r2star(joinpath(root, file))
                end
            end
        end

    elseif isfile(path)
        _run_r2star(path)

    else
        throw(ArgumentError("$path does not exist"))
    end

    return nothing
end


function _run_r2star(file::AbstractString)
    nii = niread(file)

    hdr = nii.header
    mag = nii.raw

    r2s = r2star_ll(mag, TEs)
    file1 = replace(file, ".nii" => "_loglinear.nii")
    niwrite(file1, NIVolume(hdr, r2s))

    r2s = r2star_arlo(mag, TEs)
    file1 = replace(file, ".nii" => "_arlo.nii")
    niwrite(file1, NIVolume(hdr, r2s))

    r2s = r2star_crsi(mag, TEs)
    file1 = replace(file, ".nii" => "_crsi.nii")
    niwrite(file1, NIVolume(hdr, r2s))

    return nothing
end