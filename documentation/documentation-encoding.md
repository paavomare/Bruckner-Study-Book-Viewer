## Encoding documentation

This documentation provides information about the decisions made to encode the phenomena found in the *Kitzler Study Book*. 

The encoding rules of this project are mainly derived from the [official MEI Guidelines v4.0.1](https://music-encoding.org/guidelines/v4/content/). Elements, attributes and attribute values were extended, where default values did not suffice to model the *Kitzler Study Book* in MEI in a satisfying way. Furthermore, we customized the MEI schema using an ODD to exclude several unnecessary modules and elements. 

All editorial corrections or decisions (using the elements `<sic>`, `<corr>`, and `<supplied>`) mention the responsible person via `@resp`. 

Notes, which only consist of a head with no stem, get a duration value based on their relative position in the measure or by comparison with similar succession of notes in other measures or by discussing and deciding on a reasonable value.

Tuplet numbers are regularized and displayed in the digital edition, when they are not present in the *Kitzler Study Book*.

When possible, the position of symbols and text indicating dynamics, ornamentation, tempo, etc. in the digital edition is identical to the position in the *Kitzler Study Book*. If not, the positioning is tacitly adjusted. 

You can find further information about our approach and use of certain MEI elements in the following list in alphabetical order.

---

#### &lt;add&gt;


This element contains material, which replaces material or is obviously added by Bruckner or Kitzler after writing the first version. Information about writing in pencil is given by `@hand=”#Bleistift”`. 

---

#### &lt;annot&gt;

This element contains extensive annotations written by Bruckner. A `<p>` element containing the text is nested within `<annot>`. `<lb>`, `<abbr>`, `<expan>`, and `<rend>` provide further information about the layout and appearance of the text. The attribute `@type` defines what kind of annotation is given. The values are: “description”, “question”, “answer”, “questionmark”, “date”, “title”, “pitchname”, and “NB”. The attribute `@plist` points to other elements to specify the semantic position.



---

#### &lt;beatRpt&gt;

This element is used to encode a repeat symbol for a single beat. A certain number of subsequent `<beatRpt>` elements is replaced by a `<mRpt>` when possible. This simplifies the resolving of the repeat symbols into the desired content for the automatic music analysis. 

---

#### &lt;cpMark&gt;

This element is used to encode instructions or indications (such as “etc.” or “like above”) intended to result in filling gaps in the score with material written elsewhere. The attributes `@origin.startid` and `@origin.endid` are necessary to reference the measures, which are to be inserted, as well as `@tstamp` and `@tstamp2`, which are used to state the position of the inserted content in the new measure. For the source view, the cpMarks are processed via XSLT and `choice` elements with `abbr` and `expan` containing the copied material and the abbreviation (in fact, a `space`) are inserted. For the work view, the `abbr` elements are deleted to show only the semantic text, not the scripture.

---

#### &lt;del&gt;

This element contains material that has been deleted. To specify the kind of the deletion, we use different values for the attribute `@rend`: “strike”, “erased”, and “overwritten”. The last two values were added to the schema for this particular project. Information about writing in pencil is given by `@hand=”#Bleistift”`. 

---

#### &lt;dir&gt;

This element contains short remarks by Bruckner, which are relevant for the evaluation of a section, segment or part of an exercise or composition and therefore need to be displayed in the digital edition for further context. Such as:
1.  Information about the key (“C major”, “G major”, etc.)
2.  Information about the cadence (“authentic cadence”, “plagal cadence”, etc.)
3.  Instructions (“Orglpunct”, “pizzicato”, “Solo”, etc.)
4.  Titles of segments (“Motif 1”, “II”, “G minor motif”, etc.) 

---

#### &lt;f&gt; and &lt;fb&gt;

These elements are used to encode figured bass symbols. `<f>` and `<fb>` are nested inside `<harm>` elements. If a single symbol of a two-rowed figured bass sign is deleted, the whole `<harm>` element needs to be nested in a `<subst>` construct, otherwise *Verovio* cannot render it correctly.

---

#### &lt;metaMark&gt;

This element contains symbols like ”#“, ”+“, “x”, “X”, and “§”, which indicate a connection between measures or parts. The attribute `@target` points to the referenced element. 

---

#### &lt;rest&gt;

For optimal positioning in the digital edition, `<rest>` is more closely encoded with `@oloc` and `@ploc`. The position does not represent the exact same place of the rest as in the *Kitzler Study Book*. `@oloc` and `@ploc` is only used to ensure that no elements collide. 

---

#### &lt;subst&gt;

This element is used to encode a substitution and contains the elements `<del>` and `<add>`. The image viewer enables toggling between the deleted and added material. Occasionally, it was necessary to nest `<subst>` in `<del>` as there are multiple cases, in which a substitution was eventually deleted as well.

---

#### &lt;tuplet&gt; and &lt;tupletSpan&gt;

Currently, *Verovio* does not render `<tupletSpan>` correctly, when a tuplet shares a beam with a note that is not part of the tuplet. The tuplet number will be rendered in the middle of the beam instead of in the middle of the tuplet. Another problem is the combination of `<tuplet>` and a `<subst>`-construct. In this case, 
renders the tuplet number directly above the last line or below the first line, where beams or note stems often collide with the numbers.

---
