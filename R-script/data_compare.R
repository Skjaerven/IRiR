# Om man ikke har brukt "daff"-pakken kjør: install.packages("daff")
library(daff)


# df1 = read.csv() # Choose dataset desired dataset
# 
# df2 = read.csv() # Choose dataset to compare

#Code snippet below is for demo purpose only
df1 = dat
df2 =  dat
df2[df2$id.y == 92016, "ld_dep.sf"] = 2500 #Changed from 5502 to 2500

#Use function diff_data ftom daff-package
diffs = diff_data(df1, df2, unchanged_column_context = 0L, unchanged_context = 0L)
summary(diffs)


# Percentage change from t-3 to t-2, must be applied on data configured 
delta_df = dat

# Remove columns with average data from last five years
delta_df = delta_df[,-grep("fha_", colnames(delta_df))]

lab_vars =  c("id.y",  "orgn", "comp", "y", "name", "id",
              "id_erapp2", "orgn.y", "ld_gci.dummy")



delta = (delta_df[delta_df$y == y.cb,sapply(delta_df,is.numeric)] - delta_df[delta_df$y == y.cb-1,sapply(delta_df,is.numeric)])/delta_df[delta_df$y == y.cb-1,sapply(delta_df,is.numeric)]
delta$id.y = delta_df[delta_df$y == y.cb,"id.y"]
delta[, c("y", "orgn")] = NULL
delta[is.infinite(as.matrix(delta))] = NaN

mean_delta = colMeans(delta,na.rm = TRUE)

