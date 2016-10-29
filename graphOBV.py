import pandas as pd
import numpy as np
import plotly.plotly as py
import plotly.graph_objs as go
import plotly.tools as tls


tls.set_credentials_file(username='ryanlai2', api_key='v4wricvwwj')

df = pd.read_csv('obv.csv')

df.head()

trace = go.Scatter(
                  x = df['Date'], y = df['OBV'],
                  name='On Balance Volume'
                  )
layout = go.Layout(
                  title='On Balance Value over time (2016)',
                  plot_bgcolor='rgb(230, 230,230)',
                  showlegend=True
                  )
fig = go.Figure(data=[trace], layout=layout)

py.iplot(fig, filename='obv')
