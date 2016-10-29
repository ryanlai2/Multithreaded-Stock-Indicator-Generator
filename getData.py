import yahoo_finance
import pandas as pd

symbol = yahoo_finance.Share("amd")
google_data = symbol.get_historical("2015-10-28", "2016-10-28")
google_df = pd.DataFrame(google_data)

# Output data into CSV
google_df.to_csv("/home/ryanlai2/241Honors/amd_stock_data.csv")
