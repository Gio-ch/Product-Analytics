import pandas as pd
from datetime import timedelta
from collections import defaultdict

def load_and_prepare_data(file_path, fill_missing_dates=False):
    """Load and prepare the data
    
    Parameters:
    - file_path (str): The path to the CSV file containing the data.
    - fill_missing_dates (bool): Flag to indicate whether to fill in missing dates in the data.
                                 If set to True, the function will fill in any missing dates in the range
                                 from the minimum to the maximum date found in the dataset.
                                 Default is False.
    Returns:
    - DataFrame: A DataFrame containing the prepared data.
    """
    df = pd.read_csv(file_path)
    df['active_date_timestamp'] = pd.to_datetime(df['active_date_timestamp']).dt.date
    
    # Create a date range that covers the full range
    if fill_missing_dates:
        full_date_range = pd.date_range(start=df['active_date_timestamp'].min(), end=df['active_date_timestamp'].max())
        full_date_range = full_date_range.map(lambda x: x.date())
        full_date_df = pd.DataFrame({'active_date_timestamp': full_date_range})
        df = pd.merge(full_date_df, df, on='active_date_timestamp', how='left')
    
    # Filter data to only include dates with 30 days of back data
    min_date = df['active_date_timestamp'].min()
    start_date = min_date + timedelta(days=30)
    return df[df['active_date_timestamp'] >= start_date]

def calculate_dau_wau_mau(df):
    """Calculate Daily, Weekly, and Monthly Active Users."""
    records = []
    for date in df['active_date_timestamp'].unique():
        daily_data = df[df['active_date_timestamp'] == date]
        dau = daily_data['user_id'].nunique()
        weekly_data = df[(df['active_date_timestamp'] >= (date - timedelta(days=6))) & (df['active_date_timestamp'] <= date)]
        wau = weekly_data['user_id'].nunique()
        monthly_data = df[(df['active_date_timestamp'] >= (date - timedelta(days=29))) & (df['active_date_timestamp'] <= date)]
        mau = monthly_data['user_id'].nunique()
        records.append({'date': date, 'dau': dau, 'wau': wau, 'mau': mau})
    
    metrics_df = pd.DataFrame.from_records(records)
    return metrics_df

def calculate_dau_wau_mau_optimized(df):
    """Calculate DAU, WAU, and MAU using an optimized method.
    
    Parameters:
    - df (DataFrame): Input data with columns 'active_date_timestamp' and 'user_id'.
    
    Returns:
    - DataFrame: A DataFrame with columns 'date', 'dau', 'wau', 'mau'.
    
    Note: This is for demonstration purpose and is not used in the main function.
    """
    date_to_user_ids = defaultdict(set)
    # Populate the dictionary only with dates that are in the DataFrame
    for _, row in df.dropna(subset=['user_id']).iterrows():
        date_to_user_ids[row['active_date_timestamp']].add(row['user_id'])
    
    records = []
    all_unique_dates = sorted(df['active_date_timestamp'].unique())
    for date in all_unique_dates:
        dau = len(date_to_user_ids[date])
        wau = len(set.union(*[date_to_user_ids[date - timedelta(days=i)] for i in range(7) if date - timedelta(days=i) in date_to_user_ids]))
        mau = len(set.union(*[date_to_user_ids[date - timedelta(days=i)] for i in range(30) if date - timedelta(days=i) in date_to_user_ids]))
        records.append({'date': date, 'dau': dau, 'wau': wau, 'mau': mau})
    
    metrics_df = pd.DataFrame.from_records(records)
    return metrics_df

def main():
    file_path = 'user_data.csv'
    df = load_and_prepare_data(file_path)
    
    # Calculate DAU, WAU, MAU
    metrics_df = calculate_dau_wau_mau(df)
    
    # Remove identified outlier date "2022-09-30"
    filtered_metrics_df = metrics_df[metrics_df['date'] != pd.Timestamp('2022-09-30').date()].copy()
    
    # Sort the DataFrame by date in descending order and reset index
    filtered_metrics_df.sort_values('date', ascending=False, inplace=True)
    filtered_metrics_df.reset_index(drop=True, inplace=True)
    
    # Display the final dau, wau, mau table
    print(filtered_metrics_df.head())
    
    # write this df to csv
    filtered_metrics_df.to_csv('dau_wau_mau.csv', index=False)


if __name__ == '__main__':
    main()
