import ring_theory.fractional_ideal
import ring_theory.discrete_valuation_ring
import linear_algebra.basic
import order.zorn
universes u v 

variables (R : Type u) [comm_ring R] {A : Type v} [comm_ring A]
variables (K : Type u) [field K] (R' : Type u) [integral_domain R']
variables [algebra R A]

open function
open_locale big_operators

structure is_integrally_closed_in : Prop :=
(inj : injective (algebra_map R A))
(closed : ∀ (a : A), is_integral R a → ∃ r : R, algebra_map R A r = a)

def is_integrally_closed_domain : Prop := ∀ {r s : R}, s ≠ 0 → (∃ (n : ℕ) (f : ℕ → R) (hf : f 0 = 1),
    ∑ ij in finset.nat.antidiagonal n, f ij.1 * r ^ ij.2 * s ^ ij.1 = 0) → s ∣ r

/-!
Any nontrivial localization of an integral domain results in an integral domain.
-/
theorem local_id_is_id [integral_domain R'] (S : submonoid R') (zero_non_mem : ((0 : R') ∉  S)) {f : localization_map S (localization S)} : 
  is_integral_domain (localization S) :=
begin
  fsplit,
    {--nontrivial localization (pair ne)
      use [f.to_fun 1, f.to_fun 0],
      contrapose! zero_non_mem,
      -- intro one_eq_zero, 
      have h2 := (localization_map.eq_iff_exists f).1 zero_non_mem,
      cases h2 with c h2, 
      convert c.property, simp at h2; simp [h2],
    },
    { exact mul_comm },
    {--bulk
      intros x y mul_eq_zero,
      cases f.surj' x with a akey,
      cases f.surj' y with b bkey,
      have h1 : x * (f.to_fun a.snd) * y * (f.to_fun b.snd) = 0,
      { rw [mul_assoc x, ← mul_comm y, ← mul_assoc, mul_eq_zero], simp },
      rw [akey, mul_assoc, bkey, ← f.map_mul', ← f.map_zero'] at h1,
      rw f.eq_iff_exists' at h1,
      cases h1 with c h1, 
      rw [zero_mul, mul_comm] at h1,
      have h2 := eq_zero_or_eq_zero_of_mul_eq_zero h1,
      cases h2 with c_eq_zero h2,
      { exfalso,
        rw ← c_eq_zero at zero_non_mem,
        exact zero_non_mem c.property },
      replace h2 := eq_zero_or_eq_zero_of_mul_eq_zero h2,
      cases h2 with a_eq_zero b_eq_zero,
      { left, rw a_eq_zero at akey,
        exact localization_map.eq_zero_of_fst_eq_zero f akey rfl },
      { right, rw b_eq_zero at bkey,
        exact localization_map.eq_zero_of_fst_eq_zero f bkey rfl },
    },
end

/-!
The localization of an integral domain at a prime ideal is an integral domain.
-/
lemma local_at_prime_of_id_is_id (P : ideal R') (hp_prime : P.is_prime) : 
  integral_domain (localization.at_prime P) :=
begin
  have zero_non_mem : (0 : R') ∉ P.prime_compl,
  { have := ideal.zero_mem P, simpa },
  have h1 := local_id_is_id R' P.prime_compl zero_non_mem,
  exact is_integral_domain.to_integral_domain (localization.at_prime P) h1,
  exact localization.of (ideal.prime_compl P),
end

/-
Chopping block: 
-- class discrete_valuation_ring [comm_ring R] : Prop :=
--     (int_domain : is_integral_domain(R))
--     (unique_nonzero_prime : ∃ Q : ideal R,
--     Q ≠ ⊥ → Q.is_prime →  (∀ P : ideal R, P.is_prime → P = ⊥ ∨ P = Q)
--     )
--     (is_pir : is_principal_ideal_ring(R))
-/


/-!
Def 1: integral domain, noetherian, integrally closed, nonzero prime ideals are maximal
-/
class dedekind_id [integral_domain R] : Prop := 
    (noetherian : is_noetherian_ring R)
    (int_closed : is_integrally_closed_domain R)
    (max_nonzero_primes : ∀ P ≠ (⊥ : ideal R), P.is_prime → P.is_maximal)
/-
Def 2: noetherian ring,
localization at each nonzero prime ideals is a DVR.

Something is a discrete valuation ring if
it is an integral domain and is a PIR and has one non-zero maximal ideal.
-/

class dedekind_dvr [integral_domain R'] : Prop :=
(noetherian : is_noetherian_ring R')
(local_dvr_nonzero_prime : ∀ P ≠ (⊥ : ideal R'), P.is_prime → 
  @discrete_valuation_ring (localization.at_prime P) (by apply local_at_prime_of_id_is_id))

/-
Def 3: every nonzero fractional ideal is invertible.

Fractional ideal: I = {r | rI ⊆ R}
It is invertible if there exists a fractional ideal J
such that IJ=R.
-/

class dedekind_inv [integral_domain R'] (f : localization_map (non_zero_divisors R') $ localization (non_zero_divisors R')) : Prop :=
  (inv_ideals : ∀ I : ring.fractional_ideal f, (∃ t : I, t ≠ 0) → (∃ J : ring.fractional_ideal f, I * J = 1))


lemma dedekind_id_imp_dedekind_dvr (W : Type u) [integral_domain W] [dedekind_id W] : dedekind_dvr W :=
begin
  refine {noetherian := dedekind_id.noetherian, local_dvr_nonzero_prime := _},
  intros P hp_nonzero hp_prime, letI := hp_prime,
  have f := localization.of (ideal.prime_compl P),
  letI := local_at_prime_of_id_is_id W P hp_prime,
  rw discrete_valuation_ring.iff_PID_with_one_nonzero_prime (localization.at_prime P),
  split, swap,
  {
    have p' := local_ring.maximal_ideal (localization.at_prime P),
    have hp' := local_ring.maximal_ideal.is_maximal (localization.at_prime P),
    --use p' does not work
    
    repeat {sorry},
  },

  repeat {sorry},
end


-- CR jstark for kenji: You don't want both of these to be instances, since that creates a loop in typeclass inference.
-- I'd guess both of these just want to be lemmas
lemma dedekind_dvr_imp_dedekind_inv [dedekind_dvr R'] (f : fraction_map R' $ localization (non_zero_divisors R')) : 
  dedekind_inv R' f :=
begin
    sorry,
end

lemma dedekind_inv_imp_dedekind_id (f : fraction_map R' $ localization (non_zero_divisors R')) [dedekind_inv R' f] : 
  dedekind_id R' :=
begin
  sorry,
end

lemma dedekind_id_imp_dedekind_inv [dedekind_id R'] (f : fraction_map R' $ localization (non_zero_divisors R')) : dedekind_inv R' f :=
by {letI := dedekind_id_imp_dedekind_dvr R', exact dedekind_dvr_imp_dedekind_inv R' f,}

lemma dedekind_inv_imp_dedekind_dvr (f : fraction_map R' $ localization (non_zero_divisors R')) [dedekind_inv R' f] : dedekind_dvr R' :=
by {letI := dedekind_inv_imp_dedekind_id R', exact dedekind_id_imp_dedekind_dvr R',}

lemma dedekind_dvr_imp_dedekind_id (f : fraction_map R' $ localization (non_zero_divisors R')) [dedekind_dvr R'] : dedekind_id R' :=
by {letI := dedekind_dvr_imp_dedekind_inv R', exact dedekind_inv_imp_dedekind_id R' f,}

/-
Time to break a lot of things !

probably morally correct: fractional ideals have prime factorization !
(→ regular ideals have prime factorization)

-/

open_locale classical

/-
Currently mathlib has the following two characteristics of Noetherian modules
(i) - Every ascending chain of ideals is eventually constant i.e. I_1 ⊂ I_2 ⊂ I_3 ⊂ … ⊂ I_n ⊂ I_{n+1} = I_n
(ii) - Every ideal is finitely generated
This is the third that mathlib does not have (pertaining to rings, perhaps to modules(?)):
(iii) - Every non-empty set S of ideals has a maximal member. i.e. if M ⊂ I, then I = R ∨ I = M

Proof of equivalence: by mathlib (i) ↔ (ii).

(i → iii) - This is just the statement of Zorn's lemma applied to the poset of elements of S ordered under inclusion.
(iii → ii) - Let I be an ideal. Take S to be the set of subideals of I which are finitely generated. 
Then the maximal element of S has to equal I.
-/
--this is not in mathlib for some reason(???)
lemma in_submodule_span_of_gen_set {X : Type u} [ring R'] [add_comm_group X] [module R' X] 
{s : set X} {x : X} (h : x ∈ s) : x ∈ (submodule.span R' s) := 
submodule.subset_span h

    -- rcases mfg with ⟨ Mgen , Mgenkey⟩,
    -- use ↑Mgen, split, { apply finset.finite_to_set },
    -- convert Mgenkey, apply max,

theorem set_has_maximal_iff_noetherian {X : Type u} [add_comm_group X] [module R' X] : (∀(a : set $ submodule R' X), a.nonempty → ∃ (M ∈ a), ∀ (I ∈ a), M ≤ I → I=M) ↔ is_noetherian R' X := 
begin
  split; intro h,
  { split,
    intro I,
    let S := {J : submodule R' X | J ≤ I ∧ J.fg},
    have h2 : S.nonempty, { use (⊥ : submodule R' X), convert submodule.fg_bot, simp },
    rcases h S h2 with ⟨ M, ⟨hMI, ⟨Mgen, hMgen⟩⟩, max⟩,
    rw submodule.fg_def,
    contrapose! max,
    have : ∃ x ∈ I, x ∉ M,
    { 
      have := max ↑Mgen (finset.finite_to_set Mgen), 
      contrapose! this, 
      rw hMgen, ext, tauto },
    rcases this with ⟨x, hxI, hxM⟩,
    use submodule.span R' (↑Mgen ∪ {x}), split,
    { split,
      { suffices : (↑Mgen : set X) ∪ {x} ⊆ I, { convert submodule.span_mono this, simp },
        have : (↑Mgen : set X) ⊆ M, { convert submodule.subset_span, cc },
        apply set.union_subset, { exact set.subset.trans this hMI }, { simp [hxI] } }, 
      { rw submodule.fg_def, use (↑Mgen ∪ {x}), split, { split, exact additive.fintype, }, refl } },
    split, 
    { rw ← hMgen, convert submodule.span_mono _, simp },
    { contrapose! hxM, rw ← hxM, apply submodule.subset_span, exact (↑Mgen : set X).mem_union_right rfl, } },
  { rintros A ⟨a, ha⟩, 
    rw is_noetherian_iff_well_founded at h, 
    rw rel_embedding.well_founded_iff_no_descending_seq at h,
    by_contra hyp,
    push_neg at hyp,
    apply h,
    constructor,
    have h' : ∀ (M : submodule R' X), M ∈ A → (∃ (I : submodule R' X), I ∈ A ∧ M < I),
    {
      intros m mina,
      rcases hyp m mina with ⟨I, iina, mlei, mneqi⟩,
      use I, split, exact iina, split, exact mlei, intro ilem, apply mneqi, exact le_antisymm ilem mlei,
    },
    have h'' : ∀ M : A, ∃ I : A, (M : submodule R' X) < I,
    { rintros ⟨M, M_in⟩,
      rcases h' M M_in with ⟨I, I_in, hMI⟩,
      exact ⟨⟨I, I_in⟩, hMI⟩ },
    let f : ℕ → A := λ n, nat.rec_on n ⟨a, ha⟩ (λ n M, classical.some (h'' M)),
    exact rel_embedding.nat_gt (coe ∘ f) (λ n, classical.some_spec (h'' $ f n)),
  },
end

lemma set_has_maximal [is_noetherian_ring R'] (a : set $ ideal R') (ha : a.nonempty): ∃ (M ∈ a), ∀ (I ∈ a), M ≤ I → I = M :=
begin
  have : is_noetherian R' R' := by assumption,
  rw ← set_has_maximal_iff_noetherian at this,
  exact this _ ha,
end


--ring with id is most general(?)
lemma lt_add_nonmem (I : ideal R') (a ∉ I) : I < I+ideal.span{a} :=
begin
  have blah : ∀ (x y : ideal R'), x ≤ x ⊔ y, 
  { intros x y, simp only [le_sup_left],},
  split, exact blah I (ideal.span{a}),
  have blah2 : ∀ (x y z : ideal R'),  x ⊔ y ≤ z → x ≤ z → y ≤ z,
  { intros x y z, simp only [sup_le_iff], tauto,},
  have h : I ≤ I, exact le_refl I,
  rw ideal.add_eq_sup,
  intro bad,
  have h1 := blah2 I (ideal.span{a}) I bad h,
  have h2 : a ∈ ideal.span{a},
  { rw ideal.mem_span_singleton', use 1, rw one_mul,},
  have : ∀ (x ∈ ideal.span{a}), x ∈ I, simpa only [],
  exact H (this a h2),
end

lemma zero_prime [integral_domain R'] : (⊥ : ideal R').is_prime :=
begin
  split,
  {
    intro,
    have h1 := (ideal.eq_top_iff_one) (⊥ : ideal R'),
    rw h1 at a,
    have : 1 = (0 : R'), tauto,
    simpa,
  },
  {
    intros,
    have h1 : x * y = 0, tauto,
    have x_or_y0 : x = 0 ∨ y = 0,
    exact zero_eq_mul.mp (eq.symm h1),
    tauto,
  },
end

namespace dedekind


/-
Suppose not, then the set of ideals that do not contain a product of primes is nonempty, and by set_has_maximal
must have a maximal element M.
Since M is not prime, ∃ (r,s : R-M) such that rs ∈ M.
Since r ∉ M, M+(r) > M, and since M is maximal, M+(r) and M+(s) must be divisible by some prime.
Now observe that (M+(r))(M+(s)) is divisible by some primes, but M*M ⊂ M, rM ⊂ M, sM ⊂ M, and rs ⊂ M, so
this is contained in M, but this is a contradiction.
-/
lemma ideal_contains_prime_product [dedekind_id R'] (I : ideal R') (gt_zero : ⊥ < I) : ∃(plist : list $ ideal R'), plist.prod ≤ I ∧ (∀(P ∈ plist), ideal.is_prime P ∧ ⊥ < P) :=
begin
  letI : is_noetherian_ring R', exact dedekind_id.noetherian,
  by_contra hyp,
  push_neg at hyp,
  let A := {J : ideal R' | ∀(qlist : list $ ideal R'), qlist.prod ≤ J → (∃ (P : ideal R'), P ∈ qlist ∧ (P.is_prime → ¬⊥ < P))},
  have key : A.nonempty,
  {use I, exact hyp,},
  rcases set_has_maximal R' A key with ⟨ M, Mkey, maximal⟩,
  rw set.mem_set_of_eq at Mkey,
  by_cases M = ⊥,
  {
    have h1 := maximal I,
    have h2 : I ∈ A, simpa,
    rw h at h1,
    have h3 := h1 h2,
    have h4 : ⊥ ≤ I,
    {cases gt_zero, exact gt_zero_left,},
    cases gt_zero,
    have := h3 h4,
    rw this at *, tauto,
  },
  by_cases M.is_prime,
  {
    have : [M].prod ≤  M, rw list.prod_singleton, exact le_refl M,
    sorry,
  },
  repeat{sorry},
end

/-
--what is this even trying to prove? chopping block 2.0
lemma ideal_contains_prime_product [dedekind_id R'] (I : ideal R') (gt_zero : ⊥  < I ) : ∃ (plist : list $ ideal R'), plist.prod ≤ I ∧ (∀(P ∈  plist), ideal.is_prime P ∧ ⊥ < P ) :=
begin
  /- IMPORTANT NOTE: some things here work that work for the wrong reasons (read: ne_top)
  -/
  letI : is_noetherian_ring R', exact dedekind_id.noetherian,
  by_contradiction hyp,
  push_neg at hyp,
  let A := {J : ideal R' | ∀(qlist : list $ ideal R'), qlist.prod ≤ J → (∃(P ∈ qlist), ideal.is_prime(P) →  ¬⊥ < P)}, 
  have key : A.nonempty,
  { use I, simpa only [exists_prop, set.mem_set_of_eq],},

  rcases set_has_maximal R' A key with ⟨ M, Mkey, maximal⟩,
  rw set.mem_set_of_eq at Mkey,
  by_cases M = ⊥,
  {
    have h1 := maximal I,
    have h2 : I ∈ A, simpa,
    rw h at h1,
    have h3 := h1 h2,
    have h4 : ⊥ ≤ I,
    { cases gt_zero, exact gt_zero_left,},
    cases gt_zero,
    have := h3 h4,
    rw this at *, tauto,
  },
  have h1 : ¬ M.is_prime,
  {
    by_contradiction,
    have h1 := Mkey [M],
    rw list.prod_singleton at h1,
    have : M ≤ M, exact le_refl M,
    rcases h1 this with ⟨ P, Pkey, hp ⟩,
    have blah: P = M, exact list.mem_singleton.mp Pkey, 
    
    rw blah at hp,
    have hp' := hp a,
    clear' h1 Pkey this blah hp P,
    sorry,
  },
  unfold ideal.is_prime at h1,
  push_neg at h1,
  have ne_top : M ≠ ⊤ , sorry,
  have h2 := h1 ne_top,
  rcases h2 with ⟨r,s,rs_in_m, r_nin_m, s_nin_m⟩,
  set ray := M + ideal.span({r}) with mr,
  have hmr : M < ray,
  { exact lt_add_nonmem R' M r r_nin_m,},
  set say := M + ideal.span({s}) with ms,
  have hms : M < say,
  { exact lt_add_nonmem R' M s s_nin_m,},
  clear r_nin_m s_nin_m ne_top,
  have main : ray*say ≤ M,
  {--bashing simplifications, I think this would be a very nice simp tactic
    rw [ms,mr,left_distrib,right_distrib,right_distrib,← add_assoc],
    repeat {rw [ideal.add_eq_sup]},
    have blah : ∀ (x y z : ideal R'), x ≤ z → y ≤ z → x ⊔ y ≤ z, simp only [sup_le_iff], tauto,
    have part1 : M*M ≤ M, exact ideal.mul_le_left,
    have part2 : ideal.span{r} * M ≤ M, exact ideal.mul_le_left,
    have part3 : M*ideal.span{s} ≤ M, exact ideal.mul_le_right,
    have part4' : ideal.span {r} * ideal.span {s} = (ideal.span{r*s} : ideal R'),
    {
      unfold ideal.span,
      rw [submodule.span_mul_span, set.singleton_mul_singleton],
    },
    rw part4',
    have part4 : ideal.span{r*s} ≤ M,
    { rw ideal.span_le, simpa,},
    have h1 := blah (M*M) (ideal.span{r} * M ⊔  M * ideal.span {s} ⊔  ideal.span{r*s}) M part1,
    rw [←sup_assoc,← sup_assoc] at h1,
    apply h1,
    clear' h1 part1,
    have h1 := blah (ideal.span{r} * M) (M * ideal.span{s} ⊔ ideal.span{r*s}) M part2,
    rw [←sup_assoc] at h1,
    apply h1, clear' h1 part2,
    exact blah (M * ideal.span{s}) (ideal.span {r*s}) M part3 part4,
  },
  have say_contains_prime : ∃ (P : ideal R'), P.is_prime ∧ say < P,
  {--sketch: since M < say and M is maximal of the set, say is not in A, and so has prime factor
    sorry,
  },
  --there are too many variables that may or may not be needed....
  rcases say_contains_prime with ⟨ P , P_prime , P_dvd⟩,
  --have h2 : P ∣ M, {sorry,},
  --clear' P_dvd,
  --exact Mkey P P_prime h2,
  sorry,
end
-/
/-
For any proper ideal I, there exists an element, γ,  in K (the field of fractions of R) such that 
γ I ⊂ R.
Proof: This is really annoying.
Pick some a ∈ I, then (a) contains a product of primes, and fix P_1, … such that
P_1…P_r ⊂ (a), etc.

broken, not sure how to state it.

lemma frac_mul_ideal_contains_ring [dedekind_id R'] (I : ideal R') (h_nonzero : I ≠ ⊥) (h_nontop : I ≠ ⊤ ) : ∃ (γ : fraction_ring R'), γI ⊂ R :=
begin
  sorry,
end

-/

/-
For any ideal I, there exists J such that IJ is principal.
proof:
Let 0 ≠ α ∈ I, and let J = { β ∈ R : β I ⊂ (α )}.
We can see that J is an ideal.
and we have that IJ ⊂ (α).
Since IJ ⊂ (α), we have that A = IJ/α is an ideal of R.

If A = R, then IJ = (α) and we are done,
otherwise, A is a proper ideal, and we can use frac_mul_ideal_contains_ring
to have a γ ∈ K-R such that γ A ⊂ R. Since R is integrally closed,
it suffices to show that γ is a root of a monic polynomial over R.

We have that J ⊂ A, as α ∈ I. so γ J ⊂ γ A ⊂ R.
We make the observation that γ J ⊂ J. (rest is sketchy and annoying)

Need to refine conditions (mainly non-zero).
-/
lemma exists_ideal_prod_principal [dedekind_id R'](I : ideal R') : ∃ (J : ideal R'), (I * J).is_principal ∧ (J ≠ ⊥ ) :=
begin
  sorry,
end


--this seems true, should check!
lemma ideal_mul_eq_zero [integral_domain R'] {I J : ideal R'} : (I * J = ⊥) ↔ I = ⊥ ∨ J = ⊥ :=
begin
  have hJ : inhabited J, by exact submodule.inhabited J,
  have j := inhabited.default J, clear hJ,
  split, swap,
  { intros,
    cases a,
    {rw [← ideal.mul_bot J, a, ideal.mul_comm],},
    {rw [← ideal.mul_bot I, a, ideal.mul_comm],},
  },
  intro hij,
  by_cases J = ⊥,
  tauto,
  left,
  rw submodule.eq_bot_iff,
  intros i hi,
  rcases J.ne_bot_iff.1 h with ⟨ j', hj, ne0⟩,
  rw submodule.eq_bot_iff at hij,
  specialize hij (i * j'),
  have := eq_zero_or_eq_zero_of_mul_eq_zero ( hij (ideal.mul_mem_mul hi hj)),
  tauto,
end

--this is probably useless and cumbersome to use (if ever used)
lemma prod_principal_eq_zero_iff_eq_zero [dedekind_id R'] (I : ideal R')
(J : ideal R') (hj : (I*J).is_principal) (nonzero : (J ≠ ⊥ )) : (I * J) = ⊥ ↔ I = ⊥ :=
begin
  split, swap,
  {intro, rw a, simp,},
  intro h,
  have h1 := (ideal_mul_eq_zero(R')).1 h,
  cases h1, exact h1, simpa only [],
end


lemma ddk_mul_right_inj [dedekind_id R'] (A B C : ideal R') (A ≠ ⊥ ) : A * B = A * C ↔ B=C :=
begin
  symmetry,
  split,
  {intro, rw a,},
  rcases exists_ideal_prod_principal(R')(A) with ⟨ J ,Jkey, ne_bot⟩,
  intro ab_eq_ac,
  have : J * A * B = J * A  * C,
  {rw [mul_assoc, ab_eq_ac,mul_assoc],},
  rw mul_comm(J)(A) at this,
  
  sorry,
end
/-
TODO: Refactor ddk_left_inj to be more like mul_left_inj
-/
lemma ddk_left_inj [dedekind_id R'] (A B C : ideal R') ( C ≠ ⊥ ) : A * C = B * C ↔ A = B :=
begin
  rw [mul_comm(A), mul_comm(B)],
  have h1 := ddk_mul_right_inj R' C A B C H, --why does this require so many args?
  exact h1,
end

--This is currently dead wrong
lemma ideal_prime_factorization [dedekind_id R'] (I : ideal R') : ∃ (pset : finset $ ideal R'), ∃(powset : finset $ ℕ ), (finset.card pset = finset.card powset) ∧ (∀(P ∈  pset), ideal.is_prime(P)) ∧ false :=
begin
  sorry,  
end

--every nonzero ideal has an element that's not 0
lemma nonzero_mem_of_neq_bot [integral_domain R'] (I : ideal R') (gt_bot : ⊥ < I) : ∃ a : I, a ≠ 0 :=
begin
  have h := (submodule.lt_iff_le_and_exists.1 gt_bot).2,
  clear gt_bot,
  rcases h with ⟨ x, hx, key ⟩,
  use [x, hx],
  simp only [submodule.mem_bot] at key,
  simpa only [ne.def, submodule.mk_eq_zero],
end

--every ideal is generated by at most two elements of dedekind domain
lemma two_generators [dedekind_id R'] (I : ideal R')  : ∃ ( a b : R'), I = ideal.span {a,b} :=
begin
  by_cases ⊥ < I,
  tactic.swap,
  { 
    have h1 : I = ⊥ ,
    sorry,
    use (0 : R'), use (0 : R'), rw h1, simp,
  },
  have h1 := nonzero_mem_of_neq_bot R' I h,
  cases h1 with a a_neq_zero,
  use a,
  
  sorry,
end
end dedekind