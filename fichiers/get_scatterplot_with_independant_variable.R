# function get_scatterplot_with_independant_variable
#
# Build a scatterplot with different point colors according to the modalities of the selected independent variable.
# If requested, correlation coefficients are displayed in the legend (overall and for each modality of the independent variable).
# Required arguments:
# - dataset: the data frame with data to be plotted
# - x_variable: character, the name of the quantitative variable displayed on the x axis
# - y_variable: character, the name of the quantitative variable displayed on the y axis
# - independent_variable: character, the name of the qualitative variable to define groups plotted with separate colours
# Optional arguments:
# - scaleX: 2D numeric vector (default NULL), used to specifiy x axis limits to be used in the plot, if NULL the scale will be set automatically
# - scaleY: 2D numeric vector (default NULL), used to specifiy y axis limits to be used in the plot, if NULL the scale will be set automatically
# - display_generated_figure: logical (default TRUE), if TRUE the plot will be displayed
# - display_correlation_coefficients_in_legend: logical (default FALSE), if TRUE the correlation coefficients are displayed in the legend, both for the whole dataset and for each modality of the independent variable
# - use_rank_correlation: logical (default FALSE, ignored if display_correlation_coefficients_in_legend is FALSE), if TRUE the correlation coefficients will be computed using Spearman rank correlation instead of default Pearson correlation
# - figure_title: character (default NULL), the optional title to be displayed on top of the figure
# - exported_file_name: character (default NULL), if not NULL the generated figure will be exported to file using the specified file name and path (image format depends on file extension, e.g. .pdf or .png)
# Return value: a handle to the generated plot
#
# Nicolas Audibert, LPP UMR7018, last change July 2018

get_scatterplot_with_independant_variable <- function(
  dataset,
  x_variable,
  y_variable,
  independent_variable,
  display_generated_figure=TRUE,
  display_correlation_coefficients_in_legend=FALSE,
  use_rank_correlation=FALSE,
  figure_title=NULL,
  exported_file_name=NULL,
  scaleX=NULL,
  scaleY=NULL
  ) {
  
  library(plyr)
  library(ggplot2)
  
  # Build base figure
  fig = ggplot(dataset) + 
    geom_point(aes_string(x=x_variable, y=y_variable, colour=independent_variable)) +
    xlab(x_variable) +
    ylab(y_variable) +
    theme_bw()
  
  # Add title if requested
  if(!is.null(figure_title))
    fig = fig +
      ggtitle(figure_title)
  
  # Display correlation coefficients if requested 
  if(display_correlation_coefficients_in_legend) {
    # Get independent variable modalities names and corresponding correlation coefficient
    legend_elements = sort(as.character(unique(dataset[,independent_variable])))
    if(use_rank_correlation)
      correlation_method = "spearman"
    else
      correlation_method = "pearson"
    correlation_coefficients = ddply(dataset,independent_variable,function(x) cor(x[!is.nan(x[,x_variable]) && !is.nan(x[,y_variable]),x_variable],x[!is.nan(x[,x_variable]) && !is.nan(x[,y_variable]),y_variable], method = correlation_method))
    if(use_rank_correlation)
      legend_labels=paste(legend_elements," rho=",round(correlation_coefficients[,2],digits=3),sep="")
    else
      legend_labels=paste(legend_elements," r=",round(correlation_coefficients[,2],digits=3),sep="")
    fig = fig +
      scale_colour_discrete(name=paste0("r = ",round(cor(dataset[,x_variable],dataset[,y_variable]),digits=3),"\n\n",independent_variable),
                          breaks=legend_elements,
                          labels=legend_labels)
   }
  
  # set X scale if requested
  if(!is.null(scaleX) && length(scaleX)>=2)
    fig = fig + xlim(c(scaleX[1],scaleX[2]))
  # set Y scale if requested
  if(!is.null(scaleY) && length(scaleY)>=2)
    fig = fig + ylim(c(scaleY[1],scaleY[2]))
  
  # Display figure if requested
  if(display_generated_figure)
    print(fig)
  
  # Save the generated figure to file if requested
  if(!is.null(exported_file_name))
    ggsave(plot = fig, filename = exported_file_name)
  
  return(fig)
}
