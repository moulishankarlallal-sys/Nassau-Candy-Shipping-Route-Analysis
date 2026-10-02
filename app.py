"""
Nassau Candy - Shipping Route Analysis Dashboard (Streamlit) - v3

Only needs: streamlit, pandas, numpy (installed with Streamlit) + openpyxl for .xlsx.
No plotly / matplotlib / seaborn / google.colab.

Put your Excel (.xlsx) or CSV data file in the same folder as this file.
If none is found, the app shows an upload box instead of crashing.
"""

import importlib
import subprocess
import sys
from pathlib import Path
 
import numpy as np
import pandas as pd
import streamlit as st

st.set_page_config(page_title="Nassau Candy - Shipping Analysis", page_icon="🍬", layout="wide")

BASE_DIR = Path(__file__).resolve().parent


def ensure_openpyxl():
    """openpyxl is needed to read .xlsx; install it at runtime if the host missed it."""
    try:
        importlib.import_module("openpyxl")
        return True
    except ModuleNotFoundError:
        for cmd in (
            [sys.executable, "-m", "pip", "install", "openpyxl"],
            [sys.executable, "-m", "pip", "install", "--break-system-packages", "openpyxl"],
            ["uv", "pip", "install", "--python", sys.executable, "openpyxl"],
        ):
            try:
                subprocess.check_call(cmd)
                importlib.invalidate_caches()
                importlib.import_module("openpyxl")
                return True
            except Exception:
                continue
    return False


PRODUCT_FACTORY = {
    "Wonka Bar - Nutty Crunch Surprise": "Lot's O' Nuts",
    "Wonka Bar - Fudge Mallows": "Lot's O' Nuts",
    "Wonka Bar -Scrumdiddlyumptious": "Lot's O' Nuts",
    "Wonka Bar - Milk Chocolate": "Wicked Choccy's",
    "Wonka Bar - Triple Dazzle Caramel": "Wicked Choccy's",
    "Laffy Taffy": "Sugar Shack",
    "SweeTARTS": "Sugar Shack",
    "Nerds": "Sugar Shack",
    "Fun Dip": "Sugar Shack",
    "Fizzy Lifting Drinks": "Sugar Shack",
    "Everlasting Gobstopper": "Secret Factory",
    "Lickable Wallpaper": "Secret Factory",
    "Wonka Gum": "Secret Factory",
    "Hair Toffee": "The Other Factory",
    "Kazookles": "The Other Factory",
}

REQUIRED = ["Order ID", "Order Date", "Ship Date", "Ship Mode", "State/Province",
            "Region", "Product Name", "Sales", "Units", "Gross Profit"]


# ------------------------------------------------------------------ data
def find_data_file():
    for pattern in ("*.xlsx", "*.xls", "*.csv"):
        files = sorted(p for p in BASE_DIR.glob(pattern) if not p.name.startswith("~$"))
        if files:
            return files[0]
    return None


def read_raw(source):
    name = getattr(source, "name", str(source)).lower()
    if name.endswith(".csv"):
        return pd.read_csv(source)
    if not ensure_openpyxl():
        raise RuntimeError("The 'openpyxl' package is required to read Excel files. "
                           "Add 'openpyxl' to requirements.txt, or upload a CSV instead.")
    xls = pd.ExcelFile(source)
    sheet = "Raw data" if "Raw data" in xls.sheet_names else xls.sheet_names[0]
    return pd.read_excel(xls, sheet_name=sheet)


def prepare(df):
    df = df.copy()
    df.columns = [str(c).strip() for c in df.columns]
    missing = [c for c in REQUIRED if c not in df.columns]
    if missing:
        raise ValueError("Missing required columns: " + ", ".join(missing))

    df["Order Date"] = pd.to_datetime(df["Order Date"], errors="coerce")
    df["Ship Date"] = pd.to_datetime(df["Ship Date"], errors="coerce")
    for c in ("Sales", "Units", "Gross Profit"):
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0)

    df["Shipping Lead Time"] = (df["Ship Date"] - df["Order Date"]).dt.days
    df["Data Quality Status"] = np.select(
        [df["Order Date"].isna(), df["Ship Date"].isna(),
         df["Ship Date"] < df["Order Date"], df["Shipping Lead Time"] > 365],
        ["Missing Order Date", "Missing Ship Date", "Invalid Date", "Review Date"],
        default="Valid",
    )
    df["Product Name"] = df["Product Name"].astype(str).str.strip()
    df["Factory"] = df["Product Name"].map(PRODUCT_FACTORY).fillna("Unmapped")
    df["State/Province"] = df["State/Province"].astype(str).str.strip()
    df["Region"] = df["Region"].astype(str).str.strip()
    df["Ship Mode"] = df["Ship Mode"].astype(str).str.strip()
    df["Route"] = df["Factory"] + " -> " + df["State/Province"]
    df["Order Month"] = df["Order Date"].dt.to_period("M").astype(str)
    return df


@st.cache_data(show_spinner="Loading data...")
def load_path(path_str, mtime):
    return prepare(read_raw(path_str))


@st.cache_data(show_spinner="Processing upload...")
def load_upload(data, name):
    import io
    buf = io.BytesIO(data)
    buf.name = name
    return prepare(read_raw(buf))


def summarize(frame, by, delay_days):
    g = frame.groupby(by, dropna=False)
    out = g.agg(
        Shipments=("Order ID", "count"),
        Avg_Lead_Time=("Shipping Lead Time", "mean"),
        Lead_Time_Std=("Shipping Lead Time", "std"),
        Sales=("Sales", "sum"),
        Gross_Profit=("Gross Profit", "sum"),
        Units=("Units", "sum"),
    ).reset_index()
    d = (frame["Shipping Lead Time"] > delay_days).groupby(
        [frame[b] for b in ([by] if isinstance(by, str) else by)]).mean().mul(100)
    d = d.reset_index()
    d.columns = (([by] if isinstance(by, str) else list(by)) + ["Delay_Pct"])
    out = out.merge(d, on=by, how="left")
    out["Lead_Time_Std"] = out["Lead_Time_Std"].fillna(0)
    out["Gross_Margin_Pct"] = np.where(out["Sales"] != 0, out["Gross_Profit"] / out["Sales"] * 100, 0)
    return out.round(2)


def table(frame):
    st.dataframe(frame.rename(columns=lambda c: str(c).replace("_", " ")), hide_index=True)


# ------------------------------------------------------------------ load
st.title("🍬 Nassau Candy - Shipping Route Analysis")
st.sidebar.caption("App version: v2 (no plotly/matplotlib)")

path = find_data_file()
df_all = None
try:
    if path is not None:
        df_all = load_path(str(path), path.stat().st_mtime)
        st.caption(f"Data file: {path.name}")
    else:
        st.info("No data file found next to this app. Upload the Nassau Candy Excel or CSV file.")
        up = st.file_uploader("Upload data file", type=["xlsx", "xls", "csv"])
        if up is not None:
            df_all = load_upload(up.getvalue(), up.name)
except Exception as exc:
    st.error(f"Could not read the data file: {exc}")
    st.stop()

if df_all is None or df_all.empty:
    st.stop()

# ------------------------------------------------------------------ filters
st.sidebar.header("Filters")
valid_only = st.sidebar.checkbox("Only records with valid dates", value=True)
base = df_all[df_all["Data Quality Status"] == "Valid"] if valid_only else df_all
if base.empty:
    st.warning("No records match. Untick the data-quality box in the sidebar.")
    st.stop()

factories = sorted(base["Factory"].unique())
regions = sorted(base["Region"].unique())
modes = sorted(base["Ship Mode"].unique())
sel_f = st.sidebar.multiselect("Factory", factories, default=factories)
sel_r = st.sidebar.multiselect("Region", regions, default=regions)
sel_m = st.sidebar.multiselect("Ship Mode", modes, default=modes)

lead = base["Shipping Lead Time"].dropna()
max_lead = max(int(lead.max()) if not lead.empty else 30, 1)
delay_days = st.sidebar.slider("Delay threshold (days)", 0, max_lead, min(5, max_lead))
min_ship = st.sidebar.number_input("Minimum shipments for rankings", 1, 1000, 10)

df = base[base["Factory"].isin(sel_f) & base["Region"].isin(sel_r) & base["Ship Mode"].isin(sel_m)]
if df.empty:
    st.warning("No data for these filters. Widen your selection in the sidebar.")
    st.stop()

# ------------------------------------------------------------------ KPIs
sales, gp = df["Sales"].sum(), df["Gross Profit"].sum()
avg_lead = df["Shipping Lead Time"].mean()
c = st.columns(6)
c[0].metric("Shipments", f"{len(df):,}")
c[1].metric("Sales", f"${sales:,.0f}")
c[2].metric("Gross Profit", f"${gp:,.0f}")
c[3].metric("Gross Margin", f"{(gp / sales * 100 if sales else 0):.1f}%")
c[4].metric("Avg Lead Time", f"{avg_lead:.1f} d" if pd.notna(avg_lead) else "n/a")
c[5].metric("Delay Rate", f"{(df['Shipping Lead Time'] > delay_days).mean() * 100:.1f}%")
st.divider()

t1, t2, t3, t4, t5 = st.tabs(["Overview", "Routes", "Geography", "Ship Modes", "Data & Quality"])

# ------------------------------------------------------------------ Overview
with t1:
    fac = summarize(df, "Factory", delay_days).sort_values("Shipments", ascending=False)
    a, b = st.columns(2)
    with a:
        st.subheader("Shipments by Factory")
        st.bar_chart(fac.set_index("Factory")["Shipments"])
    with b:
        st.subheader("Average Lead Time by Factory (days)")
        st.bar_chart(fac.set_index("Factory")["Avg_Lead_Time"])
    a, b = st.columns(2)
    with a:
        st.subheader("Sales vs Gross Profit by Factory")
        st.bar_chart(fac.set_index("Factory")[["Sales", "Gross_Profit"]])
    with b:
        st.subheader("Monthly Shipment Volume")
        monthly = df.dropna(subset=["Order Date"]).groupby("Order Month").size().sort_index()
        if monthly.empty:
            st.info("No monthly data available.")
        else:
            st.line_chart(monthly.rename("Shipments"))
    st.subheader("Factory summary")
    table(fac)

# ------------------------------------------------------------------ Routes
with t2:
    routes = summarize(df, ["Route", "Factory", "State/Province"], delay_days)
    rf = routes[routes["Shipments"] >= min_ship]
    n = st.slider("Routes to show", 5, 25, 10)
    a, b = st.columns(2)
    with a:
        st.subheader(f"Top {n} routes by volume")
        st.bar_chart(routes.sort_values("Shipments", ascending=False).head(n).set_index("Route")["Shipments"],
                     horizontal=True)
    with b:
        if rf.empty:
            st.info(f"No routes have at least {min_ship} shipments.")
        else:
            st.subheader(f"Fastest {n} routes (avg days)")
            st.bar_chart(rf.sort_values("Avg_Lead_Time").head(n).set_index("Route")["Avg_Lead_Time"],
                         horizontal=True)
    if not rf.empty:
        st.subheader(f"Slowest {n} routes (avg days)")
        st.bar_chart(rf.sort_values("Avg_Lead_Time", ascending=False).head(n).set_index("Route")["Avg_Lead_Time"],
                     horizontal=True)
        lo, hi = routes["Avg_Lead_Time"].min(), routes["Avg_Lead_Time"].max()
        rf = rf.copy()
        rf["Efficiency_Score"] = (100 * (hi - rf["Avg_Lead_Time"]) / (hi - lo)).round(1) if hi != lo else 100.0
        st.subheader("Route table (higher score = faster)")
        table(rf.sort_values("Efficiency_Score", ascending=False))

# ------------------------------------------------------------------ Geography
with t3:
    states = summarize(df, ["State/Province", "Region"], delay_days)
    metric = st.selectbox("Metric", ["Shipments", "Avg_Lead_Time", "Delay_Pct", "Sales", "Gross_Profit"],
                          format_func=lambda x: x.replace("_", " "))
    a, b = st.columns(2)
    with a:
        st.subheader(f"Top 15 states by {metric.replace('_', ' ')}")
        st.bar_chart(states.groupby("State/Province")[metric].sum().sort_values(ascending=False).head(15),
                     horizontal=True)
    with b:
        reg = summarize(df, "Region", delay_days)
        st.subheader("Average Lead Time by Region (days)")
        st.bar_chart(reg.set_index("Region")["Avg_Lead_Time"])
    bott = states[states["Shipments"] >= min_ship].copy()
    if not bott.empty:
        bott["Bottleneck_Index"] = bott["Shipments"].rank(ascending=False) + bott["Avg_Lead_Time"].rank(ascending=False)
        st.subheader("Potential bottleneck states (lower index = busy AND slow)")
        table(bott.sort_values("Bottleneck_Index").head(15))

# ------------------------------------------------------------------ Ship modes
with t4:
    m = summarize(df, "Ship Mode", delay_days)
    a, b = st.columns(2)
    with a:
        st.subheader("Shipments by Ship Mode")
        st.bar_chart(m.set_index("Ship Mode")["Shipments"])
    with b:
        st.subheader("Average Lead Time by Ship Mode (days)")
        st.bar_chart(m.set_index("Ship Mode")["Avg_Lead_Time"])
    st.subheader("Lead time distribution by Ship Mode")
    dist = df.dropna(subset=["Shipping Lead Time"]).groupby("Ship Mode")["Shipping Lead Time"].describe().round(2)
    st.dataframe(dist)
    table(m)

# ------------------------------------------------------------------ Data
with t5:
    q = df_all["Data Quality Status"].value_counts().rename_axis("Status").reset_index(name="Records")
    q["Percent"] = (q["Records"] / len(df_all) * 100).round(2)
    a, b = st.columns([1, 2])
    with a:
        st.subheader("Data quality")
        st.dataframe(q, hide_index=True)
        unmapped = df_all.loc[df_all["Factory"] == "Unmapped", "Product Name"].unique()
        if len(unmapped):
            st.warning("Products with no factory: " + ", ".join(unmapped))
        else:
            st.success("All products mapped to a factory.")
    with b:
        st.subheader("Filtered records (first 1,000)")
        cols = ["Order ID", "Order Date", "Ship Date", "Ship Mode", "Factory", "State/Province",
                "Region", "Product Name", "Sales", "Units", "Gross Profit", "Shipping Lead Time"]
        st.dataframe(df[cols].head(1000), hide_index=True)
    st.download_button("Download filtered data (CSV)", df.to_csv(index=False).encode("utf-8"),
                       file_name="nassau_candy_filtered.csv", mime="text/csv")
