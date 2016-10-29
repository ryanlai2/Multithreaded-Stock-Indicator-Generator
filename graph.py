import pandas as pd
import numpy as np
import plotly.plotly as py
import plotly.graph_objs as go
import plotly.tools as tls


tls.set_credentials_file(username='ryanlai2', api_key='v4wricvwwj')

df = pd.read_csv('amd_stock_data.csv')

df.head()

trace = go.Scatter(
                  x = df['Date'], y = df['Close'],
                  name='Share Prices (in USD)'
                  )
layout = go.Layout(
                  title='AMD Share Prices over time (2014)',
                  plot_bgcolor='rgb(230, 230,230)',
                  showlegend=True
                  )
fig = go.Figure(data=[trace], layout=layout)

py.iplot(fig, filename='amd-stock-prices')
