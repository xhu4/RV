function get-tiles
  fr "tds:///context/$argv[1]/feature/all_surfel_tiles_after_z_split" | string match -r "(?<=data: )\w+"
end
