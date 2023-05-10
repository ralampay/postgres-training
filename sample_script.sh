echo "Starting script..."
echo "[`date`]"
psql -U developer -d ecommerce -f demo2.sql -W
echo "Done"
