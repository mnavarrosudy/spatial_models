

if Sys.iswindows()
	serverid = "WB_mtlb_3"
	base_path = "D:/WBS/BBGD/deploy"
elseif Sys.isapple()
	serverid = "MN_mac"
	base_path = "/Users/mnavarrosudy/Dropbox/BBGD"  # Note: this will use development/'local' folder
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

mc_path = joinpath(base_path, "code", "mc_simulation.jl")

include(mc_path)

