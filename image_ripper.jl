#  The function image_ripper reads a list of URLs from a text file and downloads then into a created folder called Images

function image_ripper(file_name::String)
    rm("Images", force = true, recursive = true)
    new_folder = mkdir("Images")
    new_path = joinpath(pwd(), "Images")
    count = 1
    file = open(file_name)
    for ln in eachline(file)
        image_name = "image_" * string(count)
        if Sys.iswindows()
            slash = "\\"
        else
            slash = "/"
        end
        download_path = new_path * slash * image_name * ".jpg"
        try
            download(ln, download_path)
            count = count + 1
        catch 
            println("Download Error!")
            count = count + 1
        end
    end    
end

# This is an example of usage.  

# The file "cars" is found at: https://drive.google.com/open?id=1SF7IFTlPpgz6gKshO8au-e4Ifi-8lcNO

image_ripper("cars")
