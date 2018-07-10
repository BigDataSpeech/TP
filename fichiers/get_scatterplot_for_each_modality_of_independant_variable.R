# function get_scatterplot_for_each_modality_of_independant_variable
#
# Build a separate scatterplot (or 2D density plot) for each modality of the selected independent variable.
# If requested, correlation coefficients are displayed in plot titles.
# Required arguments:
# - dataset: the data frame with data to be plotted
# - x_variable: character, the name of the quantitative variable displayed on the x axis
# - y_variable: character, the name of the quantitative variable displayed on the y axis
# - independent_variable: character, the name of the qualitative variable to define separate plots
# Optional arguments:
# - scaleX: 2D numeric vector (default NULL), used to specifiy x axis limits to be used in plots, if NULL the scale will be set automatically to the same values for each plot
# - scaleY: 2D numeric vector (default NULL), used to specifiy y axis limits to be used in plots, if NULL the scale will be set automatically to the same values for each plot
# - display_as_2d_density_plots: logical (default FALSE), if TRUE the plots will be displayed as 2D dnesity plots instead of classical scatterplots (useful for large datasets)
# - display_generated_figures: logical (default TRUE), if TRUE the plot will be displayed
# - display_values_count: logical (default TRUE), if TRUE the number of points plotted in the figure is displayed in figures titles
# - display_correlation_coefficients: logical (default FALSE), if TRUE the correlation coefficients are displayed in figures titles
# - use_rank_correlation: logical (default FALSE, ignored if display_correlation_coefficients_in_legend is FALSE), if TRUE the correlation coefficients will be computed using Spearman rank correlation instead of default Pearson correlation
# - figures_base_title: character (default NULL), the optional base title to be displayed on top of the figure; independent variable modality and correlation coefficient if requested will be appended to this base title; if NULL, no title will be displayed
# - exported_files_basename: character (default NULL), if not NULL the generated figures will be exported to files using the specified base path, followed by the 
# - exported_files_extension: character (default ".pdf"), extension of the exported image files, defines the format to be used
# Return value: a vector with plot handles
#
# Nicolas Audibert, LPP UMR7018, last change July 2018

get_scatterplot_for_each_modality_of_independant_variable <- function(
  dataset,
  x_variable,
  y_variable,
  independent_variable,
  scaleX=NULL,
  scaleY=NULL,
  display_as_2d_density_plots=FALSE,
  display_generated_figures=TRUE,
  display_values_count=TRUE,
  display_correlation_coefficients=FALSE,
  use_rank_correlation=FALSE,
  figures_base_title=NULL,
  exported_files_basename=NULL,
  exported_files_extension=NULL
  ) {
  
  library(plyr)
  library(ggplot2)
  
  # Remove non-finite values
  dataset = dataset[is.finite(dataset[,x_variable]) & is.finite(dataset[,y_variable]),]

  # Get correlation coefficients if requested 
  correlation_coefficients = NULL
  if(display_correlation_coefficients) {
    # Get independent variable modalities names and corresponding correlation coefficient
    legend_elements = sort(as.character(unique(dataset[,independent_variable])))
    if(use_rank_correlation)
      correlation_method = "spearman"
    else
      correlation_method = "pearson"
    correlation_coefficients = ddply(dataset,independent_variable,function(x) cor(x[!is.nan(x[,x_variable]) && !is.nan(x[,y_variable]),x_variable],x[!is.nan(x[,x_variable]) && !is.nan(x[,y_variable]),y_variable], method = correlation_method))
    # fig = fig +
    #   scale_colour_discrete(name=paste0("r = ",round(cor(dataset[,x_variable],dataset[,y_variable]),digits=3),"\n\n",independent_variable),
    #                         breaks=legend_elements,
    #                         labels=paste(legend_elements," r=",round(coefs_correlation[,2],digits=3),sep=""))
  }
  
  # Get plot limits if not specified as an input argument
  if(is.null(scaleX) || length(scaleX)<2)
    scaleX = c(
      min(dataset[is.finite(dataset[,x_variable]),x_variable]),
      max(dataset[is.finite(dataset[,x_variable]),x_variable])
    )
  if(is.null(scaleY) || length(scaleY)<2)
    scaleY = c(
      min(dataset[is.finite(dataset[,y_variable]),y_variable]),
      max(dataset[is.finite(dataset[,y_variable]),y_variable])
    )
  
  # Process each modality of the independent variable
  independent_variable_modalities = levels(as.factor(dataset[,independent_variable]))
  generated_figures_handles = c()
  for(iModality in 1:length(independent_variable_modalities)) {
    current_modality = independent_variable_modalities[iModality]
    current_subset = dataset[dataset[,independent_variable]==current_modality,]
    # Build base figure
    fig = ggplot(current_subset)
    if(display_as_2d_density_plots)
      fig = fig +
        stat_density_2d(aes_string(x=x_variable, y=y_variable, fill = "..level.."), geom = "polygon")
    else
      fig = fig +
        geom_point(aes_string(x=x_variable, y=y_variable))
    fig = fig +
      xlab(x_variable) +
      ylab(y_variable) +
      theme_bw()
    # Add title
    if(!is.null(figures_base_title)) {
      current_figure_title = paste0(figures_base_title, " - ", independent_variable, "=", current_modality)
    } else {
      current_figure_title = paste0(independent_variable, "=", current_modality)
    }
    # Include the number of values plotted in the figure if requested
    if(display_values_count) {
      current_figure_title = paste0(current_figure_title, "\nN = ",nrow(current_subset))
    }
    # Include correlation coefficient in the title if requested
    if(display_correlation_coefficients) {
      current_correlation_coefficient = round(correlation_coefficients[iModality,2],digits=3)
      if(use_rank_correlation)
        current_figure_title = paste0(current_figure_title, "\nrho = ",current_correlation_coefficient)
      else
        current_figure_title = paste0(current_figure_title, "\nr = ",current_correlation_coefficient)
    }
    fig = fig +
      ggtitle(current_figure_title)
    # Set X and Y scale
    fig = fig +
      coord_cartesian(
        xlim = c(scaleX[1],scaleX[2]),
        ylim = c(scaleY[1],scaleY[2])
      )
    
    # Display figure if requested
    if(display_generated_figures)
      print(fig)
    
    # Save the generated figure to file if requested
    if(!is.null(exported_files_basename))
      ggsave(plot = fig, filename = paste0(exported_files_basename, "_" , independent_variable, "_" , current_modality, exported_files_extension))
    
    # Store the handle to the generated figure
    generated_figures_handles = c(generated_figures_handles, fig)
  }

  return(generated_figures_handles)
}
