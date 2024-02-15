"""
    SeisDifference(d1, d2; <keyword arguments>)

Plot time-space, 2D seismic data `d1`, `d2`, and their difference (`d1 - d2`) with color, wiggles or overlay.

# Arguments:
- `d1::Matrix{<:AbstractFloat}`: the measured seismic traces. Number of columns corresponds to number
                                 of traces whereas number of rows corresponds to the number of times
                                 amplitude was measured for each trace
- `d2::Matrix{<:AbstractFloat}`: same description as d1.

# Keyword Arguments:
- `fig::Figure=nothing`: the figure we want to plot on. If not supplied, one will be created and returned.

- `gx::Vector{<:Real}=nothing`: the real coordinates of the seismometers corresponding to the traces in d
- `ox=0`: first point of x-axis.
- `dx=1`: increment of x-axis.
- `oy=0`: first point of y-axis.
- `dy=1`: increment of y-axis.

- `pclip=98`: percentile for determining clip.
- `vmin=nothing`: minimum value used in colormapping data.
- `vmax=nothing`: maximum value used in colormapping data.

- `wiggle_fill_color=:black`: color for filling the positive wiggles.
- `wiggle_line_color=:black`: color for wiggles' lines.
- `wiggle_trace_increment=1`: increment for wiggle traces.
- `xcur=1.2`: wiggle excursion in traces corresponding to clip.

- `cmap=:viridis`: the colormap to be used for color and overlay plots.

- `style`: determines the type of plot. Can be either "wiggle"/"wiggles", "color", "overlay".

Return the figure and 3 axes corresponding to d1, d2, d1-d2.

# Example
```julia
julia> d1 = SeisLinearEvents(); d2 = SeisLinearEvents(); SeisDifference(d1, d2);
```
"""
function SeisDifference(d1, d2;
                        fig=nothing, ox=0, dx=1, oy=0, dy=1,  gx=nothing,
                        pclip=98, vmin=nothing, vmax=nothing, wiggle_line_color=:black, 
                        wiggle_fill_color=:black, trace_width=0.7, cmap=:viridis, style="overlay")

    if isnothing(fig)
        fig = Figure()
    end

    if style == "overlay"
        plotfunc = seisoverlaybase!
    elseif style == "wiggles" || style == "wiggle"
        plotfunc = seiswigglebase!
    else
        plotfunc = seiscolorbase!
    end

    axes = [__create_axis(fig[1, 1], ), __create_axis(fig[2, 1]), __create_axis(fig[1, 3])]
    data = [d1, d2, d1 .- d2]
    plots = []

    for (i, ax) in enumerate(axes)
        xlims!(ax, low=ox-dx, high=ox+size(d,2)*dx)
        push!(plots, plotfunc(ax, data[i], ox=ox, dx=dx, oy=oy, dy=dy, gx=gx, pclip=pclip, vmin=vmin, vmax=vmax,
                    wiggle_line_color=wiggle_line_color, wiggle_fill_color=wiggle_fill_color,
                    trace_width=trace_width, cmap=cmap))
    end

    if !(style == "wiggles" || style == "wiggle")
        Colorbar(fig[1, 2], plots[1])
        Colorbar(fig[2, 2], plots[2])
        Colorbar(fig[1, 4], plots[3])
    end

    return fig, axes[1], axes[2], axes[3]
end