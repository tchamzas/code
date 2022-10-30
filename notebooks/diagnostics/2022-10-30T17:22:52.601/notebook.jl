### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 8696264e-5877-11ed-36fa-83c27c0e0b68
begin
	# This cell activates the Pumas environment and must not be removed.
	import Pkg
	Pkg.activate(; io = devnull)
	import PumasApps
	RESULTS = PumasApps.Workspace.API.load_notebook_data(@__FILE__)
end;

# ╔═╡ 8696269e-5877-11ed-0d51-29cb9c623c79
# The `RESULTS` variable contains all selected diagnostics from the
# app. You can access them with the syntax `RESULTS.name_of_result`
# where "name_of_result" is one of the custom variable names you
# selected.

# ╔═╡ Cell order:
# ╟─8696264e-5877-11ed-36fa-83c27c0e0b68
# ╠═8696269e-5877-11ed-0d51-29cb9c623c79
