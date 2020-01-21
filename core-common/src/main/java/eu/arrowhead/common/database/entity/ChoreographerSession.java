package eu.arrowhead.common.database.entity;

import eu.arrowhead.common.CoreDefaults;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import javax.persistence.*;
import java.time.ZonedDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
public class ChoreographerSession {

    //=================================================================================================
    // members

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "planId", referencedColumnName = "id", nullable = false)
    private ChoreographerPlan plan;

    @Column(length = CoreDefaults.VARCHAR_BASIC, nullable = false)
    private String status;

    @Column(nullable = false, updatable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    private ZonedDateTime startedAt;

    @OneToMany(mappedBy = "session", fetch = FetchType.LAZY, orphanRemoval = true)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Set<ChoreographerWorklog> worklogs = new HashSet<>();

    //=================================================================================================
    // methods

    //=================================================================================================
    public ChoreographerSession() {}

    //=================================================================================================
    public ChoreographerSession(ChoreographerPlan plan, String status) {
        this.plan = plan;
        this.status = status;
    }

    //=================================================================================================
    public long getId() { return id; }
    public ChoreographerPlan getPlan() { return plan; }
    public String getStatus() { return status; }
    public ZonedDateTime getStartedAt() { return startedAt; }

    //=================================================================================================
    public void setId(long id) { this.id = id; }
    public void setPlan(ChoreographerPlan plan) { this.plan = plan; }
    public void setStatus(String status) { this.status = status; }
    public void setStartedAt(ZonedDateTime startedAt) { this.startedAt = startedAt; }

    //-------------------------------------------------------------------------------------------------
    @PrePersist
    public void onCreate() {
        this.startedAt = ZonedDateTime.now();
    }
}
