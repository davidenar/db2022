## Beskrivning

Detta är min redovisning för kursen db2022 på IT-Högskolan. Kunskaperna som redovisas är normalisering av databas, SQL samt Java mot en relationsdatabas.

[Mermaid](https://mermaid-js.github.io/mermaid/#/entityRelationshipDiagram) är ett verktyg för att rita diagram i Markdown. Istället för exemplevis Lucidchart, valde vi Mermaid, för att få grafen kodnära.


## Entity Relationship Diagram

```mermaid
erDiagram
    Student ||--o{ Phone : has
    Student }o--o| Grade : has
    Student ||--o{ StudentSchool : attends
    School ||--o{ StudentSchool : enrolls
    Student ||--o{ StudentHobby : has
    Hobby ||--o{ StudentHobby : involves

   Student {
        int StudentId
        string Name
        int GradeId
    }
    
    Phone {
        int PhoneId
        int StudentId
        tinyint IsHome 
        tinyint IsJob
        tinyint IsMobile
        string number
    }
    
    School {
        int SchoolId
        string name
        string City
    }
    
    StudentSchool {
        int StudentId
        int SchoolId
    }
    
    Hobby {
        int HobbyId
        string name
    }
    StudentHobby {
        int StudentId
        int HobbyId
    }
    
    Grade {
        int GradeId
        string name
    }
    
```

## Normalisera databas

docker exec -i iths-mysql mysql -uiths -piths < normalization.sql
