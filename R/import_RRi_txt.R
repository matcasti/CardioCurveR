#' Import RRi Signal from a TXT File and Preprocess It
#'
#' This function imports an RR interval (RRi) signal from a plain text file, where each line
#' contains one numeric RR interval (in milliseconds). The imported signal is preprocessed by
#' replacing non-realistic values (those below \code{min} or above \code{max}) with \code{NA} and then
#' removing them. Optionally, the function can remove ectopic beats using the \code{clean_outlier()} function,
#' and it can further filter the signal using \code{filter_signal()}. A time variable is computed as the cumulative
#' sum of the RR intervals (converted to minutes), and the processed data is returned as a data frame.
#'
#' The expected data format is a text file with one RR interval per line, for example:
#'
#' |\[some-file.txt\]:|
#' |------|
#' | 1312 |
#' | 788  |
#' | 878  |
#' | ...  |
#' | 813  |
#' | 788  |
#' | 783  |
#'
#' @param file A character string specifying the path to the text file containing the RRi signal.
#' @param remove_ectopic A logical value indicating whether to remove ectopic beats using the
#'   \code{clean_outlier()} function. Default is \code{TRUE}.
#' @param filter_noise A logical value indicating whether to apply a low-pass filter using
#'   \code{filter_signal()} to the imported signal. Default is \code{FALSE}.
#' @param min A numeric value specifying the minimum realistic RRi value (in milliseconds). Values below
#'   this are set to \code{NA}. Default is \code{250}.
#' @param max A numeric value specifying the maximum realistic RRi value (in milliseconds). Values above
#'   this are set to \code{NA}. Default is \code{2000}.
#' @param ... Additional arguments passed to \code{readLines()}.
#'
#' @return A data frame with two columns: \code{time} and \code{RRi}. The \code{time} column is computed as the
#'   cumulative sum of the RRi values divided by 60000 (to convert to minutes), and \code{RRi} contains the cleaned signal.
#'
#' @details
#' The function begins by checking that the input \code{file} is provided and that the options \code{remove_ectopic}
#' and \code{filter_noise} are logical values of length 1. It then reads the file using \code{readLines()},
#' converts the readings to doubles, and replaces any values outside the realistic range (defined by \code{min} and \code{max})
#' with \code{NA}. After removing missing values, the function optionally cleans the signal to remove ectopic beats
#' and applies a Butterworth low-pass filter if requested. Finally, it computes a time vector based on the cumulative sum of
#' the cleaned RRi signal and returns the result in a data frame.
#'
#' @examples
#'
#' temp_file <- tempfile(fileext = ".txt")
#'
#' cat(sim_RRi$RRi_simulated,
#'     file = temp_file,
#'     sep = "\n")
#'
#' sim_data <- import_RRi_txt(file = temp_file,
#'                            remove_ectopic = TRUE,
#'                            filter_noise = FALSE,
#'                            min = 250, max = 2000)
#'
#' head(sim_data)
#'
#' library(ggplot2)
#'
#' ggplot(sim_data, aes(time, RRi)) +
#'   geom_line(linewidth = 1/4, col = "purple") +
#'   labs(x = "Time (min)", y = "RRi (ms)",
#'        title = "Processed RRi Signal") +
#'   theme_minimal()
#'
#'
#' @export
import_RRi_txt <- function(file = NULL,
                           remove_ectopic = TRUE,
                           filter_noise = FALSE,
                           min = 250, max = 2000,
                           ...) {

  # Safety checks
  if (is.null(file)) stop("`file` can't be NULL.")
  if (!is.logical(remove_ectopic) || length(remove_ectopic) != 1)
    stop("`remove_ectopic` must be logical of length 1.")
  if (!is.logical(filter_noise) || length(filter_noise) != 1)
    stop("`filter_noise` must be logical of length 1.")

  # Import signal from file
  signal <- as.double(readLines(file, ...))

  # Replace non-realistic readings with NA
  signal[signal > max | signal < min] <- NA

  if (isTRUE(remove_ectopic)) {
   # Remove ectopic hearbeats
    signal <- clean_outlier(signal)
  }

  if (isTRUE(filter_noise)) {
   # Filter added noise in data
    signal <- filter_signal(signal, )
  }

  # Remove NA's
  signal <- signal[!is.na(signal)]

  # Create time variable based on cumulative RRi sum (in minutes)
  time <- cumsum(signal) / 60000

  # Format into a data.frame
  out <- data.frame(time = time, RRi = signal)

  return(out)
}
