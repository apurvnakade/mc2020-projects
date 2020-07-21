import .basic
import data.nat.parity
import data.finset
import .simple_graph
import tactic

noncomputable theory
open_locale classical

universes u
variables {V : Type u} [fintype V] (G : simple_graph V)
open graph finset

def KonigsbergBridges : multigraph (fin 4) :=
multigraph_of_edges [(0,1), (0,2), (0,3), (1,2), (1,2), (2,3), (2,3)]

-- def KonigsbergBridgesProblem : Prop :=
-- ¬ is_Eulerian KonigsbergBridges


open simple_graph
namespace simple_graph

-- namespace graph
-- include G
-- def degree (v : V) : ℕ := 
-- begin
--   have nbrs := neighbours G v,
--   have x : nbrs.finite,
--   exact set.finite.of_fintype(nbrs),
--   have fin_nbrs := set.finite.to_finset x,
--   exact fin_nbrs.card,
-- end
-- degree for undirected graphs

def crossed (v : V) {x y : V} (p : G.path x y) : ℕ :=
begin
  have in_edge := finset.filter {w : V | if h : G.adj w v then G.mem h p else false } univ,
  exact finset.card in_edge,
end
-- number of times v is in an edge in path x y

def has_eulerian_path : Prop := ∃ x y : V, ∃ p : G.path x y, G.is_Eulerian p

lemma no_edge_in_nil {d x y : V} (h : G.adj x y) : ¬ G.mem h (path.nil d) :=
begin
  by_contradiction,
  cases a,
end

-- no edges contained in the nil path

lemma crossed_add_edge {x y z : V} (e : G.adj x y) (p : G.path y z) (w : V) :
(w = x ∨ w = y) → (G.crossed w p + 1 = G.crossed w (e :: p)) :=
begin
  sorry,
end
-- adding an edge adds 1 to crossed if the edge contains the vertex

lemma crossed_add_non_edge {x y z : V} (e : G.adj x y) (p : G.path y z) (w : V) :
(w ≠ x ∧ w ≠ y) → (G.crossed w p = G.crossed w (e :: p)) :=
begin
  sorry,
end
-- adding an edge adds 0 to crossed if the edge does not contain the vertex

lemma path_crossed {x y : V} (p : G.path x y) (z : V) : 
nat.even (G.crossed z p) ↔ (x = y) ∨ (z ≠ x ∧ z ≠ y)
:=
begin
  -- induction p with d hd using h,
  induction p with d hd,
  -- base case
  { suffices : G.crossed z (path.nil d) = 0, simp [this],
    erw finset.card_eq_zero,
    convert finset.filter_false _,
    ext, simp, split_ifs,
    { exact no_edge_in_nil G h },
    { exact not_false },
    { apply_instance }},
  -- induction step
  -- implies condition
  cases p_ih with even_to_eq eq_to_even,
  have one_cross : G.crossed hd p_l + 1 = G.crossed hd (p_e :: p_l), { apply crossed_add_edge, tauto },
  split,
  { intro cross_even,
    by_cases h : p_s = p_t,
    have fl_even : (G.crossed z p_l).even,
    { apply eq_to_even, left, exact h },
    right, split, 
    { contrapose! fl_even, rw fl_even,
      suffices cross_one_even : (G.crossed hd p_l + 1).even, { rwa ← nat.even_succ },
      rw one_cross, rwa fl_even at cross_even },
    { contrapose! fl_even, rw fl_even,
      have one_cross : G.crossed p_t p_l + 1 = G.crossed p_t (p_e :: p_l),
      { apply crossed_add_edge, right, rw h },
      rw ← nat.even_succ, convert cross_even, rw [fl_even, ← one_cross]},

    by_cases h1 : hd = p_t, { tauto },
    right, split,
    contrapose! cross_even,
    rw [cross_even, ← one_cross, nat.even_succ, ← cross_even], 
    push_neg, apply eq_to_even,
    right, split, { rw cross_even, exact ne_of_edge G p_e },
    rwa cross_even,
    contrapose! cross_even,
    have zero_cross : G.crossed z p_l = G.crossed z (p_e :: p_l),
    apply crossed_add_non_edge,
    rw cross_even, split,
    symmetry, exact h1,
    symmetry, exact h,
    rw ← zero_cross,
    tauto,},

  -- impliedby direction
  intro eq_cond,
  by_cases z = hd,
  rw h, rw ← one_cross,
  have cross_odd : ¬ (G.crossed hd p_l).even,
  by_contradiction,
  rw ← h at a,
  have eq_cond1 := even_to_eq(a),
  cases eq_cond, cases eq_cond1,
  rw ← eq_cond1 at eq_cond,
  contrapose! eq_cond,
  exact G.ne_of_edge p_e,
  cases eq_cond1,
  rw eq_cond at h, exact eq_cond1_right(h),
  cases eq_cond, exact eq_cond_left(h),
  exact nat.even_succ.mpr cross_odd,
  
end
-- if x=y, all vertices have crossed = even, else all vertices except x and y have crossed = odd

lemma has_eulerian_path_iff : 
  G.has_eulerian_path ↔ card (filter {v : V | ¬ nat.even (G.degree v)} univ) ∈ ({0, 2} : finset ℕ) :=
sorry
-- iff the number of vertices of odd degree is 0 or 2

end simple_graph