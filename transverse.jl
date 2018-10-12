
# Make sure needed packages are installed:  Install by typing Pkg.add("Package_Name")

# Imports Pkg, DataFrames, CSV, HTTP and JSON

using Pkg, DataFrames, CSV, HTTP, JSON

# Defines a datatype called Placement, which hold information about lattitude, longitude, position and the number_of_positions

struct Placement
    latitude::Float64
    longitude::Float64
    position::Int64
    num_positions::Int64    
end

# Returns an integer pitch from a Placement object

function get_pitch(p::Placement)
    i = p.position
    n = p.num_positions
    if i == 1 && n == 1
        return(0)
    elseif i <= n / 2
        return(0)
    else
        return(15)
    end
end

# Returns an integer heading from a Placement object

function get_heading(p::Placement)
    i = p.position
    n = p.num_positions
    if i == 1 && n == 1
        return(0)
    else
        output = mod((720) * (i / n), 360)
        return(Int(output))
    end
end

# Returns a string of (latitude,longitude) coordinates from a Placement object

function get_coordinates(P::Placement)
    cordinates = string(P.latitude) * "," * string(P.longitude)
    return(cordinates)
end

# A helper function that makes a piece of the gsm API url

function gsm_api(P)
    url_init = "https://maps.googleapis.com/maps/api/streetview?size=1920x1080&location="
    coordinates = get_coordinates(P)
    pitch = get_pitch(P)
    heading = get_heading(P)
    output = url_init * coordinates * "&fov=20&heading=" * string(heading) * "&pitch=" * string(pitch) * "&key="
    return(output)
end

# A helper function that makes a piece of the meta_data url

function meta_data(P)
    url_init = gsm_api(P)
    a = url_init[1:47]
    b = url_init[48:end]
    output = a * "/metadata" * b
    return(output)
end

# This function checks if an image is returned(1) or not(0) frome a metadata url

function check_status(url::String)
    responce = HTTP.get(url)
    data = String(responce.body)
    data = JSON.parse(data)
    status = data["status"]
    if status == "OK"
        return(1)
    else
        return(0)
    end   
end

# Creates a table of meta_data URLs

function meta_data_table(file_name::String, key::String)
    df = CSV.read(file_name)
    df1 = copy(df[:,[1,2]])
    span = size(df1)[1]
    array_position = fill(1, span)
    array_num_positions = fill(1, span)
    placement_array = Placement.(df1[1], df1[2], array_position, array_num_positions)
    url_array = meta_data.(placement_array)
    df1[:Metadata_URL] = url_array .* key
    df1[:Status] = check_status.(df1[:Metadata_URL])
    CSV.write("Metadata_Links.csv", df1)
end

# Creates a table of meta_data URLs for the file_name, num_positions, and key

function api_table(file_name::String, num_positions::Int64, key::String)
    df = CSV.read(file_name)
    df1 = copy(df[:,[1,2]])
    df2 = DataFrame(Position = 1:num_positions)
    df3 = join(df1, df2, kind = :cross)
    span = size(df3)[1]
    array_num_positions = fill(num_positions, span)
    placement_array = Placement.(df3[1], df3[2], df3[3], array_num_positions)
    url_array = gsm_api.(placement_array)
    df3[:API_URL] = url_array .* key
    CSV.write("Street_View_Links.csv", df3)
    return(df3)
end

# This api_table function is overloaded with the optional paramater signiture

function api_table(file_name::String, num_positions::Int64, key::String, signature::String)
    df = api_table(file_name, num_positions, key)
    df[:API_URL] = df[:API_URL] .* "&signature=" .* signature
    CSV.write("Street_View_Links.csv", df)
    return(df)
end


# An example of usage:

api_table("KL.csv", 4, "my_key", "my_signiture")
