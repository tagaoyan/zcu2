useZ mathfunc

# Functions

zmath_round() {
        local n=$1
        if (( abs(n - floor(n)) < 0.5 ));then
                : $[floor(n)];
        else
                : $[floor(n)+1];
        fi
}
functions -M round 1 1 zmath_round

zmath_randf() {
        local a=$1
        local b=$2
        local d
        (( d = b - a ))
        : $[a+d*rand48()]
}
functions -M randf 2 2 zmath_randf

zmath_randi() {
        local a=$1
        local b=$2
        local d
        (( d = b + 1 ))
        : $[int(floor(randf(a,d)))]
}
functions -M randi 2 2 zmath_randi
