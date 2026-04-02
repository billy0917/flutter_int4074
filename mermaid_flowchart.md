# PinPin Go 拼拼樂 — App Flowcharts

## 1. App Startup

```mermaid
flowchart TD
    A([Open App]) --> B[Loading Screen]
    B --> C{App ready?}
    C -- Yes --> D[Splash Screen\nAnimated Logo]
    C -- Still loading --> B
    D --> E[Home Screen]
```

---

## 2. App Navigation Overview

```mermaid
flowchart TD
    Home([Home Screen])

    Home -->|Tap Snap & Learn| Cam[Camera Screen]
    Home -->|Tap Smart Quiz| Cam
    Home -->|Tap History| Hist[History Screen]
    Home -->|Tap Settings icon| Set[Settings Screen]

    Cam -->|Recognition successful| Res[Result Screen]
    Cam -->|Recognition failed| CamErr[Show Error Message\nTry again]

    Res -->|Tap Start Quiz| Quiz[Quiz Screen]
    Res -->|Tap Retake| Cam

    Quiz -->|All questions done| QR[Quiz Result Screen]

    QR -->|Try again| Cam
    QR -->|Go Home| Home

    Hist -->|Tap a record| HD[History Detail Screen]
    HD -->|Tap Start Quiz| Quiz
    HD -->|Tap Delete| Hist

    Set -->|Go Back| Home
```

---

## 3. Photo Recognition Flow

```mermaid
flowchart TD
    Start([User opens Camera Screen]) --> Choose{How to get a photo?}
    Choose -->|Take a photo| TakePhoto[Camera opens\nUser takes photo]
    Choose -->|Choose from gallery| Gallery[Photo gallery opens\nUser selects image]

    TakePhoto --> Preview[Photo preview shown]
    Gallery --> Preview

    Preview --> Tap{Tap Recognize}
    Tap --> AI[AI analyses the photo]

    AI --> Result{Recognition result}
    Result -->|Success| Show[Show Result Screen\nChinese word, Pinyin,\nTones, Example sentence]
    Result -->|Failed| Err[Show error message\nUser can try again]
    Err --> Preview

    Show --> Save[Word saved to History]
```

---

## 4. Quiz Flow

```mermaid
flowchart TD
    Start([Tap Start Quiz]) --> Generate[AI generates 5 questions]
    Generate --> Q{Question ready?}
    Q -- Yes --> ShowQ[Show question\nwith progress bar]
    Q -- Failed --> Err[Show error\nGo back]

    ShowQ --> Type{Question type}

    Type -->|Draw the tone| Draw[User draws tone shape\non canvas]
    Type -->|Listen and pick| Listen[Play audio\nUser picks correct character]
    Type -->|Match tone shape| Shape[User picks correct\ntone contour shape]
    Type -->|Pick correct pinyin\nor tone| MCQ[User picks from\n4 options]

    Draw --> Submit[Tap Submit]
    Submit --> AIJudge[AI checks the drawing]
    AIJudge --> Feedback

    Listen --> Pick[User selects answer]
    Shape --> Pick
    MCQ --> Pick
    Pick --> Feedback{Correct?}

    Feedback -->|Correct| Green[Green feedback]
    Feedback -->|Wrong| Red[Red feedback\nShake animation]

    Green --> Next{More questions?}
    Red --> Next

    Next -->|Yes| ShowQ
    Next -->|No| Done[Save result\nGo to Result Screen]
```

---

## 5. Tone Drawing Flow

```mermaid
flowchart TD
    Start([Draw Tone question appears]) --> Instruction[Target tone shown\ne.g. Tone 2 - Rising]
    Instruction --> Draw[User draws on canvas\nwith finger]
    Draw --> Submit[Tap Submit]
    Submit --> AICheck[AI checks if the\ndrawn shape matches the tone]
    AICheck --> Result{Correct shape?}
    Result -->|Yes| Pass[Show green tick\nPositive feedback message]
    Result -->|No| Fail[Show red cross\nShow correct tone shape]
    Pass --> Next[Move to next question]
    Fail --> Next
```

---

## 6. Learning History Flow

```mermaid
flowchart TD
    Start([Tap History on Home Screen]) --> List[Show all past words\ngrouped by date]

    List --> Action{User action}

    Action -->|Type in search bar| Search[Filter words by\nname or pinyin]
    Search --> List

    Action -->|Swipe a record left| Delete{Confirm delete?}
    Delete -->|Confirm| Removed[Word deleted\nList updates]
    Delete -->|Cancel| List
    Removed --> List

    Action -->|Tap a record| Detail[Show word detail\nPinyin, tones, example\nPast quiz scores]

    Detail --> DetailAction{User action}
    DetailAction -->|Tap speaker icon| Audio[Read word aloud]
    DetailAction -->|Tap Start Quiz| Quiz[Go to Quiz Screen]
    DetailAction -->|Tap Delete| DelConfirm{Confirm delete?}
    DelConfirm -->|Confirm| BackToList[Return to History]
    DelConfirm -->|Cancel| Detail
```

---

## 7. Settings Flow

```mermaid
flowchart TD
    Start([Open Settings]) --> Options{Choose setting}

    Options -->|Language| Lang[Toggle between\nChinese and English]
    Lang --> Options

    Options -->|Voice Speed| Speed[Adjust slider\nTap Test to preview]
    Speed --> Options

    Options -->|Clear History| Confirm{Are you sure?}
    Confirm -->|Yes| Cleared[All records deleted]
    Confirm -->|No| Options

    Options -->|Back| Home[Return to Home Screen]
```

---

## 8. Quiz Result Flow

```mermaid
flowchart TD
    Done([Quiz completed]) --> Stars[Show star rating\n1 to 3 stars based on score]
    Stars --> Score[Show score and accuracy]
    Score --> Review[Show each question result\nCorrect or wrong answers]
    Review --> Action{What next?}
    Action -->|Tap Try Again| Camera[Go to Camera Screen\nLearn a new word]
    Action -->|Tap Home| Home[Return to Home Screen]
```
