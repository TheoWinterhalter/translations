(* Some useful tactics. *)

Require config.
Require Import config_tactics.

Require Import syntax.
Require Import tt.
Require ett ptt.
Require ptt2ett ett2ptt.
Require ett_sanity.

(* Tactic to unfold ett and ptt judgments *)
Ltac one_unfold_tt :=
  match goal with
  (* ETT *)
  | |- ett.isctx _         => unfold ett.isctx
  | |- ett.issubst _ _ _   => unfold ett.issubst
  | |- ett.istype _ _      => unfold ett.istype
  | |- ett.isterm _ _ _    => unfold ett.isterm
  | |- ett.eqctx _ _       => unfold ett.eqctx
  | |- ett.eqsubst _ _ _ _ => unfold ett.eqsubst
  | |- ett.eqtype _ _ _    => unfold ett.eqtype
  | |- ett.eqterm _ _ _ _  => unfold ett.eqterm
  (* Also in hypotheses *)
  | [ H : ett.isctx _         |- _ ] => unfold ett.isctx   in H
  | [ H : ett.issubst _ _ _   |- _ ] => unfold ett.issubst in H
  | [ H : ett.istype _ _      |- _ ] => unfold ett.istype  in H
  | [ H : ett.isterm _ _ _    |- _ ] => unfold ett.isterm  in H
  | [ H : ett.eqctx _ _       |- _ ] => unfold ett.eqctx   in H
  | [ H : ett.eqsubst _ _ _ _ |- _ ] => unfold ett.eqsubst in H
  | [ H : ett.eqtype _ _ _    |- _ ] => unfold ett.eqtype  in H
  | [ H : ett.eqterm _ _ _ _  |- _ ] => unfold ett.eqterm  in H
  (* PTT *)
  | |- ptt.isctx _         => unfold ptt.isctx
  | |- ptt.issubst _ _ _   => unfold ptt.issubst
  | |- ptt.istype _ _      => unfold ptt.istype
  | |- ptt.isterm _ _ _    => unfold ptt.isterm
  | |- ptt.eqctx _ _       => unfold ptt.eqctx
  | |- ptt.eqsubst _ _ _ _ => unfold ptt.eqsubst
  | |- ptt.eqtype _ _ _    => unfold ptt.eqtype
  | |- ptt.eqterm _ _ _ _  => unfold ptt.eqterm
  (* Also in hypotheses *)
  | [ H : ptt.isctx _         |- _ ] => unfold ptt.isctx   in H
  | [ H : ptt.issubst _ _ _   |- _ ] => unfold ptt.issubst in H
  | [ H : ptt.istype _ _      |- _ ] => unfold ptt.istype  in H
  | [ H : ptt.isterm _ _ _    |- _ ] => unfold ptt.isterm  in H
  | [ H : ptt.eqctx _ _       |- _ ] => unfold ptt.eqctx   in H
  | [ H : ptt.eqsubst _ _ _ _ |- _ ] => unfold ptt.eqsubst in H
  | [ H : ptt.eqtype _ _ _    |- _ ] => unfold ptt.eqtype  in H
  | [ H : ptt.eqterm _ _ _ _  |- _ ] => unfold ptt.eqterm  in H
  end.

Ltac unfold_tt := repeat one_unfold_tt.

(* Tactics to apply an hypothesis that could be in PTT instead of ETT
   or the converse *)
Ltac hyp :=
  unfold_tt ;
  match goal with
  | [ H : isctx ?G |- isctx ?G ] =>
    first [
      exact (ptt2ett.sane_isctx G H)
    | exact (ett2ptt.sane_isctx G H)
    | exact H
    ]
  | [ H : issubst ?sbs ?G ?D |- issubst ?sbs ?G ?D ] =>
    first [
      exact (ptt2ett.sane_issubst sbs G D H)
    | exact (ett2ptt.sane_issubst sbs G D H)
    | exact H
    ]
  | [ H : istype ?G ?A |- istype ?G ?A ] =>
    first [
      exact (ptt2ett.sane_istype G A H)
    | exact (ett2ptt.sane_istype G A H)
    | exact H
    ]
  | [ H : isterm ?G ?u ?A |- isterm ?G ?u ?A ] =>
    first [
      exact (ptt2ett.sane_isterm G u A H)
    | exact (ett2ptt.sane_isterm G u A H)
    | exact H
    ]
  | [ H : eqctx ?G ?D |- eqctx ?G ?D ] =>
    first [
      exact (ptt2ett.sane_eqctx G D H)
    | exact (ett2ptt.sane_eqctx G D H)
    | exact H
    ]
  | [ H : eqtype ?G ?A ?B |- eqtype ?G ?A ?B ] =>
    first [
      exact (ptt2ett.sane_eqtype G A B H)
    | exact (ett2ptt.sane_eqtype G A B H)
    | exact H
    ]
  | [ H : eqterm ?G ?u ?v ?A |- eqterm ?G ?u ?v ?A ] =>
    first [
      exact (ptt2ett.sane_eqterm G u v A H)
    | exact (ett2ptt.sane_eqterm G u v A H)
    | exact H
    ]
  end.

Ltac ehyp :=
  unfold_tt ;
  match goal with
  | [ H : isctx ?G |- isctx _ ] =>
    first [
      exact (ptt2ett.sane_isctx G H)
    | exact (ett2ptt.sane_isctx G H)
    | exact H
    ]
  | [ H : issubst ?sbs ?G ?D |- issubst _ _ _ ] =>
    first [
      exact (ptt2ett.sane_issubst sbs G D H)
    | exact (ett2ptt.sane_issubst sbs G D H)
    | exact H
    ]
  | [ H : istype ?G ?A |- istype _ _ ] =>
    first [
      exact (ptt2ett.sane_istype G A H)
    | exact (ett2ptt.sane_istype G A H)
    | exact H
    ]
  | [ H : isterm ?G ?u ?A |- isterm _ _ _ ] =>
    first [
      exact (ptt2ett.sane_isterm G u A H)
    | exact (ett2ptt.sane_isterm G u A H)
    | exact H
    ]
  | [ H : eqctx ?G ?D |- eqctx _ _ ] =>
    first [
      exact (ptt2ett.sane_eqctx G D H)
    | exact (ett2ptt.sane_eqctx G D H)
    | exact H
    ]
  | [ H : eqtype ?G ?A ?B |- eqtype _ _ _ ] =>
    first [
      exact (ptt2ett.sane_eqtype G A B H)
    | exact (ett2ptt.sane_eqtype G A B H)
    | exact H
    ]
  | [ H : eqterm ?G ?u ?v ?A |- eqterm _ _ _ _ ] =>
    first [
      exact (ptt2ett.sane_eqterm G u v A H)
    | exact (ett2ptt.sane_eqterm G u v A H)
    | exact H
    ]
  end.

(* A tactic to apply sanity in ptt. *)
Ltac ptt_sane :=
  match goal with
  | H : ptt.issubst ?sbs ?G ?D |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_issubst sbs G D)
  | H : ptt.issubst ?sbs ?G ?D |- ptt.isctx ?D =>
    now apply (ptt_sanity.sane_issubst sbs G D)
  | H : ptt.istype ?G ?A |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_istype G A)
  | H : ptt.isterm ?G ?u ?A |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_isterm G u A)
  | H : ptt.isterm ?G ?u ?A |- ptt.istype ?G ?A =>
    now apply (ptt_sanity.sane_isterm G u A)
  | H : ptt.eqctx ?G ?D |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_eqctx G D)
  | H : ptt.eqctx ?G ?D |- ptt.isctx ?D =>
    now apply (ptt_sanity.sane_eqctx G D)
  | H : ptt.eqsubst ?sbs ?sbt ?G ?D |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_eqsubst sbs sbt G D)
  | H : ptt.eqsubst ?sbs ?sbt ?G ?D |- ptt.isctx ?D =>
    now apply (ptt_sanity.sane_eqsubst sbs sbt G D)
  | H : ptt.eqsubst ?sbs ?sbt ?G ?D |- ptt.issubst ?sbs ?G ?D =>
    now apply (ptt_sanity.sane_eqsubst sbs sbt G D)
  | H : ptt.eqsubst ?sbs ?sbt ?G ?D |- ptt.issubst ?sbt ?G ?D =>
    now apply (ptt_sanity.sane_eqsubst sbs sbt G D)
  | H : ptt.eqtype ?G ?A ?B |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_eqtype G A B)
  | H : ptt.eqtype ?G ?A ?B |- ptt.istype ?G ?A =>
    now apply (ptt_sanity.sane_eqtype G A B)
  | H : ptt.eqtype ?G ?A ?B |- ptt.istype ?G ?B =>
    now apply (ptt_sanity.sane_eqtype G A B)
  | H : ptt.eqterm ?G ?u ?v ?A |- ptt.isctx ?G =>
    now apply (ptt_sanity.sane_eqterm G u v A)
  | H : ptt.eqterm ?G ?u ?v ?A |- ptt.istype ?G ?A =>
    now apply (ptt_sanity.sane_eqterm G u v A)
  | H : ptt.eqterm ?G ?u ?v ?A |- ptt.isterm ?G ?u ?A =>
    now apply (ptt_sanity.sane_eqterm G u v A)
  | H : ptt.eqterm ?G ?u ?v ?A |- ptt.isterm ?G ?v ?A =>
    now apply (ptt_sanity.sane_eqterm G u v A)
  end.

Ltac hyps := first [ hyp | ptt_sane ].

(* A tactic to apply sanity in ett. *)
Ltac ett_sane :=
  match goal with
  | H : ett.issubst ?sbs ?G ?D |- ett.isctx ?G =>
    now apply (ett_sanity.sane_issubst sbs G D)
  | H : ett.issubst ?sbs ?G ?D |- ett.isctx ?D =>
    now apply (ett_sanity.sane_issubst sbs G D)
  | H : ett.istype ?G ?A |- ett.isctx ?G =>
    now apply (ett_sanity.sane_istype G A)
  | H : ett.isterm ?G ?u ?A |- ett.isctx ?G =>
    now apply (ett_sanity.sane_isterm G u A)
  | H : ett.isterm ?G ?u ?A |- ett.istype ?G ?A =>
    now apply (ett_sanity.sane_isterm G u A)
  | H : ett.eqctx ?G ?D |- ett.isctx ?G =>
    now apply (ett_sanity.sane_eqctx G D)
  | H : ett.eqctx ?G ?D |- ett.isctx ?D =>
    now apply (ett_sanity.sane_eqctx G D)
  | H : ett.eqsubst ?sbs ?sbt ?G ?D |- ett.isctx ?G =>
    now apply (ett_sanity.sane_eqsubst sbs sbt G D)
  | H : ett.eqsubst ?sbs ?sbt ?G ?D |- ett.isctx ?D =>
    now apply (ett_sanity.sane_eqsubst sbs sbt G D)
  | H : ett.eqsubst ?sbs ?sbt ?G ?D |- ett.issubst ?sbs ?G ?D =>
    now apply (ett_sanity.sane_eqsubst sbs sbt G D)
  | H : ett.eqsubst ?sbs ?sbt ?G ?D |- ett.issubst ?sbt ?G ?D =>
    now apply (ett_sanity.sane_eqsubst sbs sbt G D)
  | H : ett.eqtype ?G ?A ?B |- ett.isctx ?G =>
    now apply (ett_sanity.sane_eqtype G A B)
  | H : ett.eqtype ?G ?A ?B |- ett.istype ?G ?A =>
    now apply (ett_sanity.sane_eqtype G A B)
  | H : ett.eqtype ?G ?A ?B |- ett.istype ?G ?B =>
    now apply (ett_sanity.sane_eqtype G A B)
  | H : ett.eqterm ?G ?u ?v ?A |- ett.isctx ?G =>
    now apply (ett_sanity.sane_eqterm G u v A)
  | H : ett.eqterm ?G ?u ?v ?A |- ett.istype ?G ?A =>
    now apply (ett_sanity.sane_eqterm G u v A)
  | H : ett.eqterm ?G ?u ?v ?A |- ett.isterm ?G ?u ?A =>
    now apply (ett_sanity.sane_eqterm G u v A)
  | H : ett.eqterm ?G ?u ?v ?A |- ett.isterm ?G ?v ?A =>
    now apply (ett_sanity.sane_eqterm G u v A)
  end.

(* A tactic to change between ett and ptt *)
Ltac pex :=
  match goal with
  (* Prove in ETT instead of PTT *)
  | |- ptt.isctx _         => apply ett2ptt.sane_isctx
  | |- ptt.issubst _ _ _   => apply ett2ptt.sane_issubst
  | |- ptt.istype _ _      => apply ett2ptt.sane_istype
  | |- ptt.isterm _ _ _    => apply ett2ptt.sane_isterm
  | |- ptt.eqctx _ _       => apply ett2ptt.sane_eqctx
  | |- ptt.eqsubst _ _ _ _ => apply ett2ptt.sane_eqsubst
  | |- ptt.eqtype _ _ _    => apply ett2ptt.sane_eqtype
  | |- ptt.eqterm _ _ _ _  => apply ett2ptt.sane_eqterm
  (* Prove in PTT instead of ETT *)
  | |- ett.isctx _         => apply ptt2ett.sane_isctx
  | |- ett.issubst _ _ _   => apply ptt2ett.sane_issubst
  | |- ett.istype _ _      => apply ptt2ett.sane_istype
  | |- ett.isterm _ _ _    => apply ptt2ett.sane_isterm
  | |- ett.eqctx _ _       => apply ptt2ett.sane_eqctx
  | |- ett.eqsubst _ _ _ _ => apply ptt2ett.sane_eqsubst
  | |- ett.eqtype _ _ _    => apply ptt2ett.sane_eqtype
  | |- ett.eqterm _ _ _ _  => apply ptt2ett.sane_eqterm
  end.
