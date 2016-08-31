#!zsh
# script to read images and compare with reference images and generate a side_diff comparison image used in blog post
# needs imagemagick installed

ims=('1' '4' '5' '6')

for im in $ims; do
    echo "Processing ${im}"
    for f in ${im}_*.png; do
        echo -n $f
        echo -n " "
        compare -metric AE -fuzz 5% ${im}.png $f Diff_$f
        convert $f -background transparent -fill cyan -gravity SouthEast -annotate 0 ${f:2:r} Lbl_$f
        convert Diff_$f -background transparent -fill cyan -gravity SouthEast -annotate 0 ${f:2:r} Lbl_Diff_$f
        echo ""
    done


    cp ${im}.png tmp_${im}.png
    compare ${im}.png tmp_${im}.png Diff_${im}.png
    rm tmp_${im}.png

    convert ${im}.png Lbl_${im}_*.png +append Side_${im}.png
    convert Diff_${im}.png Lbl_Diff_${im}_*.png +append Side_Diff_${im}.png
    convert Side_${im}.png Side_Diff_${im}.png -append Side_${im}${im}.png
    mv Side_${im}${im}.png Side_${im}.png
    #rm Side_Diff_$im.png
    #rm Side_$im.png
    #rm Diff_$im*.png
    #rm Lbl_$im_*.png
    #rm Lbl_Diff_*.png
done


