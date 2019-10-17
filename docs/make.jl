using Documenter, Merly

makedocs(format = Documenter.HTML(),
         modules = [Merly],
         sitename = "Merly.jl"
         )
deploydocs(
	repo = "github.com/codeneomatrix/Merly.jl.git"
	#devbranch = "master",
    #devurl = "dev",
    #versions = ["stable" => "v^", "v#.#", "devurl" => devurl]
    )
