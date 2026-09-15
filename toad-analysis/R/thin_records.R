#' Thin occurrence records to one per grid cell
#'
#' Occurrence records tell you where people looked, not where animals are.
#' Records cluster on roads, near towns, and wherever someone with a phone
#' happened to be standing. Thinning keeps one record per `km` and discards the
#' rest, so that dense sampling in one place counts once rather than three
#' hundred times.
#'
#' @section How this one works:
#' This lays a grid over the records and keeps the first record in each cell. It
#' is an approximation. Exact thinning guarantees that no two retained records
#' are within `km` of each other, which a grid does not: two records either side
#' of a cell boundary can be metres apart and both survive. The `spThin` package
#' does the exact version, and is much slower for it.
#'
#' Cell width is corrected by the cosine of latitude, because a degree of
#' longitude is about 109 km at the top of Australia and about 80 km at the
#' bottom. Without that, southern cells would be much narrower than northern
#' ones.
#'
#' @section Choosing `km`:
#' There is no principled way to choose this. Lamboley and Fourcade (2024)
#' tested filtering distances up to 1000 km and found no optimal value, and
#' further found that spatial filtering never improved model performance enough
#' to give accurate predictions. Boria et al. (2014) found the opposite. Both
#' are worth reading before you rely on this.
#'
#' Thinning is not the only response to sampling bias. Phillips et al. (2009)
#' fix the problem in the background sample instead, by drawing background
#' points with the same bias as the presences.
#'
#' @param occurrences A data frame with `decimalLongitude` and `decimalLatitude`
#'   columns.
#' @param km Grid cell width in kilometres.
#'
#' @return `occurrences`, with rows removed. Column structure is unchanged.
#'
#' @references
#' Aiello-Lammens, M.E., Boria, R.A., Radosavljevic, A., Vilela, B., &
#' Anderson, R.P. (2015). spThin: an R package for spatial thinning of species
#' occurrence records for use in ecological niche models. *Ecography*, 38(5),
#' 541-545. \doi{10.1111/ecog.01132}
#'
#' Boria, R.A., Olson, L.E., Goodman, S.M., & Anderson, R.P. (2014). Spatial
#' filtering to reduce sampling bias can improve the performance of ecological
#' niche models. *Ecological Modelling*, 275, 73-77.
#' \doi{10.1016/j.ecolmodel.2013.12.012}
#'
#' Lamboley, Q., & Fourcade, Y. (2024). No optimal spatial filtering distance
#' for mitigating sampling bias in ecological niche models. *Journal of
#' Biogeography*. \doi{10.1111/jbi.14854}
#'
#' Phillips, S.J., Dudik, M., Elith, J., Graham, C.H., Lehmann, A., Leathwick,
#' J., & Ferrier, S. (2009). Sample selection bias and presence-only
#' distribution models. *Ecological Applications*, 19(1), 181-197.
#' \doi{10.1890/07-2153.1}
thin_records <- function(occurrences, km = 10) {
  km_per_degree <- 111
  cell_height <- km / km_per_degree

  occurrences |>
    mutate(
      cell_y = floor(decimalLatitude / cell_height),
      cell_x = floor(
        decimalLongitude * cos(decimalLatitude * pi / 180) / cell_height
      )
    ) |>
    group_by(cell_x, cell_y) |>
    slice_head(n = 1) |>
    ungroup() |>
    select(-cell_x, -cell_y)
}
