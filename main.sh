#!/bin/bash

aritmetik_ifade() { #Ornek (2+6*7)/8
	while true; do
		read -p "İfade girin: " a
		if [[ "$a" == "q" || "$a" == "Q" ]]; then
    		break
		fi
		echo "scale=5; $a" | bc -l	
	done
	}

us_al() { #Ornek 2 3 -> Sonuc 8
	while true; do
		read -p "taban & üs :" a b
		if [[ "$a" == "q" || "$a" == "Q" ]]; then
    		break
		fi
		echo "scale=5; $a^$b" | bc -l	
	done
}

karakok() {
	while true; do
		read -p "Sayi :" a 
		if [[ "$a" == "q" || "$a" == "Q" ]]; then
    		break
		fi
		echo "scale=5; sqrt($a)" | bc -l	
	done
}

trigonometri() {
	while true; do
		read -p "sin/cos x :" a b
		if [[ "$a" == "q" || "$a" == "Q" ]]; then
    		break
		elif [[ "$a" == "sin" || "$a" == "SIN" ]]; then
    		echo "scale=5; s($b)" | bc -l
		elif [[ "$a" == "cos" || "$a" == "COS" ]]; then
    		echo "scale=5; c($b)" | bc -l
		else
			echo "Geçersiz"
		fi	
	done
}

# Polinom parametrelerini almak
polinomYapisi(){
    numParam=$#
    params=("$@")
    ifade=""
    x=0
    for (( i=$(($#-1)); i>-1; i-- )) do
        if (( i == 0 )); then
            ifade+="${params[$x]}"
        elif ((i == 1)); then
            ifade+="${params[$x]}x + "
        else
            ifade+="${params[$x]}x^$i + "
        fi
        ((x+=1))
    done
    echo $ifade
}

# Polinom değerini kullanıcıdan alınan x değeri ile hesaplamak
degerHesapla(){
    numParam=$#
    params=("$@")
    sonuc=0
    j=$((numParam-1))

    read -p "x degeri: " x
	if [[ "$x" == "q" || "$x" == "Q" ]]; then
    		return 1
	fi
    for (( i=0; i < $numParam; i++ )); do
        (( sonuc += params[j] * x**i ))
        ((j-=1))
    done
    echo "--------------"
    echo "| f($x) = $sonuc |"
    echo "--------------"
}

# Polinom değerini verilen x değeriyle hesaplamak
paraDegerHesapla(){
    x=${1}            # İlk parametre = x değeri
    shift             # x'i array'den çıkar
    params=("$@")     # Geriye kalan parametreler = katsayılar

    numParam=${#params[@]}
    sonuc=0

    for (( i=0; i<numParam; i++ )); do
        j=$((numParam - 1 - i))
        (( sonuc += params[j] * x**i ))
    done

    echo $sonuc
}

# Grafik çizme fonksiyonu
ciz(){
    numParam=$#
    params=("$@")
    read -p "Aralık girin (başlangıç bitiş): " aD uD
    clear
    polinomYapisi "${params[@]}"  # Polinomu ekrana yazdırma
    scale=0.2
    for ((i=$aD; i <= $uD; i++)); do
        y=$(paraDegerHesapla "$i" "${params[@]}")
        y_scaled=$(echo "$y * $scale" | bc -l)
        y_int=$(printf "%.0f" "$y_scaled")
		j=0
        printf "%2d|" "$i"
        while (( j<$y_int )); do
            printf " "
            ((j+=1))
        done
        printf "*\n"
    done
    printf "__________________________________________________________________________\n"
}

polinom_hesap(){
	echo "Polinom parametrelerini girin (örneğin: 1 2 3 4):"
    read -a params
	polinomYapisi "${params[@]}"
    while true; do
		degerHesapla "${params[@]}"
		if [[ $? -eq 1 ]]; then
            break
        fi
    done
}
grafik_ciz(){
	echo "Polinom parametrelerini girin (örneğin: 1 2 3 4):"
    read -a params
	polinomYapisi "${params[@]}"
	ciz "${params[@]}"
	}

while true; do
	echo "------ Hesap Makinesi ------"
	echo "1) Aritmetik ifade hesaplama 2) Üs alma        3) Karakök "
	echo "4) Trigonometrik ifade       5) Polinom hesap  6) Grafik çizme"
	echo "7) BOŞ       				   8) BOŞ  			 9) BOŞ"
	echo -n "Seçim yap: "
	read secim

	case $secim in
	1)
		aritmetik_ifade
		
		;;
	2)
		us_al
		;;
	3)
		karakok
		;;
	4)
		trigonometri
		;;
	5)
		polinom_hesap
		;;
	6)
		grafik_ciz
		;;
	7)
		
		;;
	8)
		
		;;
	9)
		
		;;
	*)
		;;
	esac

done
