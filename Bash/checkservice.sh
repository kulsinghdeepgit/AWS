
#!/bin/bash
names='<any url>'
for name in $names
do
echo $name
curl --connect-timeout 3 $name
done