# Initialize Pkg manager
using Pkg

# Install or update necessary packages
Pkg.add("ZipFile")
Pkg.add("LinearAlgebra")
Pkg.add("Images")
Pkg.add("JLD2")
Pkg.add("StatsBase")
Pkg.add("Optim")
Pkg.add("DelimitedFiles")

# Initialize necessary packages
using ZipFile, LinearAlgebra, Images, JLD2, StatsBase, Optim, DelimitedFiles

# Define a function to unzip a file in Julia.
function unzip(file, exdir="")
    fileFullPath = isabspath(file) ?  file : joinpath(pwd(),file)
    basePath = dirname(fileFullPath)
    outPath = (exdir == "" ? basePath : (isabspath(exdir) ? exdir : joinpath(pwd(),exdir)))
    isdir(outPath) ? "" : mkdir(outPath)
    zarchive = ZipFile.Reader(fileFullPath)
    for f in zarchive.files
        fullFilePath = joinpath(outPath,f.name)
        if (endswith(f.name,"/") || endswith(f.name,"\\"))
            mkdir(fullFilePath)
        else
            write(fullFilePath, read(f))
        end
    end
    close(zarchive)
end

# Set the url from which we get the deploy zip file.
deploy_url = "https://github.com/mnavarrosudy/spatial_models/raw/main/BBGD/deploy.zip"

if Sys.iswindows()
	serverid = "WB_mtlb_3"
    rm("D:\\wb610020\\BBGD\\deploy", force = true, recursive = true) # Remove old folder if exists. mkdir does not allow to overwrite.
    download(deploy_url, "D:\\wb610020\\BBGD\\deploy.zip") # Download deploy zip file from github.
    unzip("D:\\wb610020\\BBGD\\deploy.zip", "D:\\wb610020\\BBGD") # Unzip deploy in BBGD folder.
    rm("D:\\wb610020\\BBGD\\deploy.zip") # Remove deploy zip file.
	#base_path = "D:/WBS/BBGD/deploy"
    base_path = "D:\\wb610020\\BBGD\\deploy" # Note: Matias does not have access to write on the WBS folder.
elseif Sys.isapple()
	serverid = "MN_mac"
    rm("/Users/mnavarrosudy/Dropbox/BBGD/deploy", force = true, recursive = true) # Remove old folder if exists. mkdir does not allow to overwrite.
    download(deploy_url, "/Users/mnavarrosudy/Dropbox/BBGD/deploy.zip") # Download deploy zip file from github.
    unzip("/Users/mnavarrosudy/Dropbox/BBGD/deploy.zip", "/Users/mnavarrosudy/Dropbox/BBGD") # Unzip deploy in BBGD folder.
    rm("/Users/mnavarrosudy/Dropbox/BBGD/deploy.zip") # Remove deploy zip file.
	base_path = "/Users/mnavarrosudy/Dropbox/BBGD/deploy"  # Note: this will use development/'local' folder
elseif Sys.islinux()
	try 
        # Reminder: try is a local scope, so if we want to keep something that is defined within it we need to store as global
        global serverid = read("/home/wb547641/.server_identifier.txt", String)    # Expecting WB_linuxSP_userAM OR WB_linuxST_userAM OR WB_linuxPE_userAM
		global base_path = "/Data/BBGD/deploy"
		# Note, if we deploy to other linux servers then base_path will depend on contents of serverid
	catch
		try 
            global serverid = read("/home/610020/.server_identifier.txt", String)  	# Expecting WB_linuxSP_userMN OR WB_linuxST_userMN OR WB_linuxPE_userMN
			global base_path = "/Data/BBGD/deploy"
			# Note, if we deploy to other linux servers then base_path will depend on contents of serverid
		catch 
			try 
                global serverid = read("/home/aim/.server_identifier.txt", String) 	# Expecting AM_at or AM_cl or AM_do
				global base_path = "/home/aim/Dropbox/BBGD/deploy"
				# Note, if AM deploys to other linux servers at home then base_path will depend on contents of serverid
			catch
				println("Server is linux, but server identifier file not found")
            end
        end
	end
else
	println("OS unknown")
end


# Maybe override the base path depending on whether AM_at or AM_cl

println(base_path)
println(serverid) #the stuff that is in file we read

cd(base_path)

mc_path = joinpath(base_path, "code", "run_mc_iterations.jl")

include(mc_path)